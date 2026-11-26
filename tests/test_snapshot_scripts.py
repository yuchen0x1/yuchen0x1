"""Offline regression tests for the public snapshot maintenance scripts."""

import importlib.util
import json
import tempfile
import unittest
import urllib.error
from pathlib import Path
from unittest.mock import MagicMock, patch


ROOT = Path(__file__).resolve().parent.parent


def load_script(name):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), ROOT / "scripts" / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sync = load_script("sync-public-index")
research = load_script("research-profiles")


def repository(name, private=False):
    return {"name": name, "html_url": f"https://github.com/example/{name}", "private": private}


class PublicIndexTests(unittest.TestCase):
    def test_personal_listing_fetches_every_page(self):
        first = [repository(f"repo-{number}") for number in range(100)]
        last = [repository("last")]
        with patch.object(sync, "github_json", side_effect=[first, last]) as request:
            self.assertEqual(sync.list_repositories("example"), first + last)
        self.assertEqual(request.call_count, 2)
        self.assertIn("type=owner", request.call_args_list[0].args[0])
        self.assertTrue(request.call_args_list[1].args[0].endswith("&page=2"))

    def test_organization_listing_requests_only_public_and_paginates(self):
        first = [repository(f"repo-{number}") for number in range(100)]
        with patch.object(sync, "github_json", side_effect=[first, []]) as request:
            self.assertEqual(sync.list_repositories("example", organization=True), first)
        self.assertIn("/orgs/example/repos?type=public", request.call_args_list[0].args[0])
        self.assertEqual(request.call_count, 2)

    def test_empty_listing_stops(self):
        with patch.object(sync, "github_json", return_value=[]) as request:
            self.assertEqual(sync.list_repositories("example"), [])
        request.assert_called_once()

    def test_exactly_full_page_fetches_empty_last_page(self):
        first = [repository(f"repo-{number}") for number in range(100)]
        with patch.object(sync, "github_json", side_effect=[first, []]) as request:
            self.assertEqual(sync.list_repositories("example"), first)
        self.assertEqual(request.call_count, 2)
        self.assertTrue(request.call_args.args[0].endswith("&page=2"))

    def test_page_limit_stops_unbounded_pagination(self):
        full_page = [repository(f"repo-{number}") for number in range(100)]
        with patch.object(sync, "github_json", return_value=full_page) as request:
            with self.assertRaisesRegex(RuntimeError, "100-page safety limit"):
                sync.list_repositories("example")
        self.assertEqual(request.call_count, 100)
        self.assertTrue(request.call_args.args[0].endswith("&page=100"))

    def test_malformed_listings_are_rejected(self):
        for value in ({"message": "unexpected"}, [None], [{"name": "repo"}], [{"name": "", "private": False}]):
            with self.subTest(value=value), patch.object(sync, "github_json", return_value=value):
                with self.assertRaisesRegex(RuntimeError, "Invalid repository listing"):
                    sync.list_repositories("example")

    def test_output_directory_and_private_filtering(self):
        public = repository("public")
        private = repository("private", private=True)
        organization = [repository(name) for name in sync.TRACKED_ORGANIZATION_REPOSITORIES]
        organization.extend([repository("untracked"), private])
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / "snapshots"
            with patch.object(sync, "list_repositories", side_effect=[[private, public], organization]):
                sync.main(["--output-dir", str(destination)])
            files = list(destination.glob("public-index-*.json"))
            self.assertEqual(len(files), 1)
            records = json.loads(files[0].read_text(encoding="utf-8"))
        self.assertEqual({record["slug"] for record in records}, {"public"} | sync.TRACKED_ORGANIZATION_REPOSITORIES)
        self.assertTrue(all(not record["private"] for record in records))
        self.assertEqual(records[0]["owner"], "yuchen0x1")

    def test_missing_or_private_tracked_repository_does_not_write(self):
        for private in (False, True):
            organization = [repository(name) for name in sync.TRACKED_ORGANIZATION_REPOSITORIES if name != "themes"]
            if private:
                organization.append(repository("themes", private=True))
            with self.subTest(private=private), tempfile.TemporaryDirectory() as temporary:
                destination = Path(temporary) / "snapshots"
                with patch.object(sync, "list_repositories", side_effect=[[], organization]):
                    with self.assertRaisesRegex(RuntimeError, "themes"):
                        sync.main(["--output-dir", str(destination)])
                self.assertFalse(destination.exists())

    def test_later_page_failure_is_not_treated_as_success(self):
        with patch.object(sync, "github_json", side_effect=[[repository(str(n)) for n in range(100)], urllib.error.URLError("offline")]):
            with self.assertRaises(urllib.error.URLError):
                sync.list_repositories("example")


class ProfileResearchTests(unittest.TestCase):
    def test_readme_detection_uses_official_endpoint_for_any_readme_name(self):
        for full_name in ("owner/lowercase-readme", "owner/docs-readme-rst", "owner/github-readme"):
            with self.subTest(full_name=full_name), patch.object(research, "github", return_value=None) as request:
                self.assertTrue(research.readme_present(full_name))
            request.assert_called_once_with(f"https://api.github.com/repos/{full_name}/readme", method="HEAD")

    def test_readme_404_is_false(self):
        error = urllib.error.HTTPError("url", 404, "not found", None, None)
        with patch.object(research, "github", side_effect=error):
            self.assertFalse(research.readme_present("owner/missing"))

    def test_readme_other_failures_propagate(self):
        for error in (urllib.error.HTTPError("url", 403, "rate limited", None, None), urllib.error.HTTPError("url", 500, "server error", None, None), urllib.error.URLError("offline")):
            with self.subTest(error=error), patch.object(research, "github", side_effect=error):
                with self.assertRaises(type(error)):
                    research.readme_present("owner/repo")

    def test_head_request_does_not_read_response_body(self):
        response = MagicMock()
        with patch.dict(research.os.environ, {"GITHUB_TOKEN": "test-token"}), patch.object(research.urllib.request, "urlopen", return_value=response) as request:
            self.assertIsNone(research.github("https://api.github.com/repos/owner/repo/readme", method="HEAD"))
        self.assertEqual(request.call_args.args[0].method, "HEAD")
        response.__enter__.return_value.read.assert_not_called()

    def test_github_requires_token(self):
        with patch.dict(research.os.environ, {}, clear=True):
            with self.assertRaisesRegex(RuntimeError, "GITHUB_TOKEN"):
                research.github("https://api.github.com/graphql")

    def test_output_directory_and_compatible_metadata(self):
        search = {"items": [{"full_name": f"owner/repo-{number}"} for number in range(30)]}
        data = {f"r{number}": {"nameWithOwner": f"owner/repo-{number}", "url": f"https://github.com/owner/repo-{number}", "object": {"entries": [{"name": "readme.md", "type": "blob"}]}} for number in range(30)}
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / "snapshots"
            with patch.object(research, "github", side_effect=[search, {"data": data}]) as request, patch.object(research, "readme_present", return_value=True) as readme:
                research.main(["--output-dir", str(destination)])
            files = list(destination.glob("profile-research-*.json"))
            self.assertEqual(len(files), 1)
            records = json.loads(files[0].read_text(encoding="utf-8"))
        self.assertEqual(len(records), 30)
        self.assertTrue(all(record["readmePresent"] for record in records))
        self.assertEqual(readme.call_count, 30)
        self.assertIn("is%3Apublic", request.call_args_list[0].args[0])
        query = request.call_args_list[1].args[1]["query"]
        self.assertNotIn("Blob{text}", query)
        self.assertNotIn("HEAD:README.md", query)

    def test_incomplete_search_and_graphql_errors_do_not_write(self):
        search = {"items": [{"full_name": f"owner/repo-{number}"} for number in range(30)]}
        cases = [[{"items": []}], [search, {"errors": [{"message": "unavailable"}]}], [search, {"data": {"r0": None}}]]
        for responses in cases:
            with self.subTest(responses=responses), tempfile.TemporaryDirectory() as temporary:
                destination = Path(temporary) / "snapshots"
                with patch.object(research, "github", side_effect=responses):
                    with self.assertRaises(RuntimeError):
                        research.main(["--output-dir", str(destination)])
                self.assertFalse(destination.exists())


if __name__ == "__main__":
    unittest.main()
