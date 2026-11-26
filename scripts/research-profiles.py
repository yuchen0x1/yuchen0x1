"""Collect public evidence for a bounded GitHub profile README landscape review.

Requires Python 3 and GITHUB_TOKEN. Writes a dated JSON snapshot; never edits README.
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path


def github(url, payload=None, method=None):
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise RuntimeError("GITHUB_TOKEN is required for GitHub API research")
    body = json.dumps(payload).encode() if payload is not None else None
    request = urllib.request.Request(
        url,
        data=body,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "User-Agent": "profile-readme-research",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        method=method,
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return None if method == "HEAD" else json.load(response)


def readme_present(full_name):
    try:
        github(f"https://api.github.com/repos/{full_name}/readme", method="HEAD")
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return False
        raise
    return True


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "docs",
        help="Directory for the dated JSON snapshot (default: docs)",
    )
    args = parser.parse_args(argv)
    search = github(
        "https://api.github.com/search/repositories?"
        "q=topic%3Agithub-profile-readme%20stars%3A%3E50%20archived%3Afalse%20is%3Apublic"
        "&sort=stars&order=desc&per_page=30"
    )
    repositories = search.get("items", [])
    if len(repositories) != 30:
        raise RuntimeError(f"Expected 30 repositories, received {len(repositories)}")
    fields = []
    for index, repo in enumerate(repositories):
        owner, name = repo["full_name"].split("/", 1)
        fields.append(
            f'r{index}:repository(owner:{json.dumps(owner)},name:{json.dumps(name)})' + "{"
            "url nameWithOwner description stargazerCount forkCount updatedAt pushedAt "
            "licenseInfo{spdxId} primaryLanguage{name} "
            "defaultBranchRef{target{... on Commit{history(first:1){nodes{committedDate messageHeadline}}}}} "
            "issues(states:OPEN,first:1,orderBy:{field:UPDATED_AT,direction:DESC}){totalCount nodes{title updatedAt}} "
            "releases(first:1,orderBy:{field:CREATED_AT,direction:DESC}){nodes{tagName publishedAt}} "
            "object(expression:\"HEAD:\"){... on Tree{entries{name type}}} "
            "}"
        )
    result = github("https://api.github.com/graphql", {"query": "query{" + " ".join(fields) + "}"})
    if result.get("errors"):
        raise RuntimeError(json.dumps(result["errors"], ensure_ascii=False))
    output = []
    for index in range(30):
        repo = result["data"].get(f"r{index}")
        if repo is None:
            raise RuntimeError(f"Missing repository at position {index}")
        repo["readmePresent"] = readme_present(repo["nameWithOwner"])
        output.append(repo)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    destination = args.output_dir / f"profile-research-{date.today().isoformat()}.json"
    destination.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Saved {len(output)} GitHub profile references to {destination}")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, urllib.error.URLError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
