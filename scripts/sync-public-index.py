"""Capture public repository facts for a profile-index review.

The README stays curated by hand. This script only records the public GitHub
facts used to review that copy, including repositories migrated to the
Indifference-Project organization.
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path


TRACKED_ORGANIZATION_REPOSITORIES = {
    "Codex-Remote-Bridge",
    "Qzone-Archive",
    "themes",
}


def github_json(url):
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "profile-index-sync",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def list_repositories(owner, organization=False):
    if organization:
        url = f"https://api.github.com/orgs/{owner}/repos?type=public&sort=full_name&per_page=100"
    else:
        url = f"https://api.github.com/users/{owner}/repos?type=owner&sort=full_name&per_page=100"
    repositories = []
    page = 1
    while True:
        batch = github_json(f"{url}&page={page}")
        if not isinstance(batch, list) or any(
            not isinstance(repository, dict)
            or not isinstance(repository.get("name"), str)
            or not repository["name"]
            or not isinstance(repository.get("private"), bool)
            for repository in batch
        ):
            raise RuntimeError(f"Invalid repository listing for {owner}, page {page}")
        repositories.extend(batch)
        if len(batch) < 100:
            return repositories
        if page >= 100:
            raise RuntimeError(f"Repository listing for {owner} exceeded the 100-page safety limit")
        page += 1


def repository_record(repository, owner):
    return {
        "owner": owner,
        "slug": repository["name"],
        "url": repository["html_url"],
        "description": repository.get("description"),
        "language": repository.get("language"),
        "fork": repository.get("fork", False),
        "archived": repository.get("archived", False),
        "private": repository.get("private", False),
        "default_branch": repository.get("default_branch"),
        "stars": repository.get("stargazers_count", 0),
        "pushed_at": repository.get("pushed_at"),
        "updated_at": repository.get("updated_at"),
        "license": (repository.get("license") or {}).get("spdx_id"),
        "topics": repository.get("topics", []),
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "docs",
        help="Directory for the dated JSON snapshot (default: docs)",
    )
    args = parser.parse_args(argv)
    personal = {
        repo["name"]: repository_record(repo, "yuchen0x1")
        for repo in list_repositories("yuchen0x1")
        if not repo.get("private")
    }
    organization = {
        repo["name"]: repository_record(repo, "Indifference-Project")
        for repo in list_repositories("Indifference-Project", organization=True)
        if not repo.get("private") and repo["name"] in TRACKED_ORGANIZATION_REPOSITORIES
    }
    missing = TRACKED_ORGANIZATION_REPOSITORIES - organization.keys()
    if missing:
        raise RuntimeError(
            "Tracked public organization repositories are missing: " + ", ".join(sorted(missing))
        )
    records = [personal[name] for name in sorted(personal)]
    records.extend(organization[name] for name in sorted(organization))
    args.output_dir.mkdir(parents=True, exist_ok=True)
    destination = args.output_dir / f"public-index-{date.today().isoformat()}.json"
    destination.write_text(json.dumps(records, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Saved {len(records)} public repository records to {destination}")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, urllib.error.URLError, KeyError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
