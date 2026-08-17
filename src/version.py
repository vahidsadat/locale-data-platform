import sys
import re
import subprocess
from pathlib import Path

VERSION_FILE = Path("./src/__init__.py")

def run_git_command(command: list[str]) -> None:
    try:
        subprocess.run(command, check= True, capture_output= True, text= True)
    except subprocess.CalledProcessError as e:
        print(f"Git Error running {' '.join(command)}: {e.stderr.strip()}")
        sys.exit(1)

def bump_version(action: str) -> None:
    if not(VERSION_FILE.exists()):
        print("Error: couldn't find {VERSION_FILE}")
        sys.exit(1)
    
    content = VERSION_FILE.read_text()
    match = re.search(r'__version__\s*=\s*["\']([^"\']+)["\']',content)

    if not match:
        print("Error: couldn't find __version__ string")
        sys.exit(1)
    
    current_version = match.group(1)
    major, minor, patch = map(int, current_version.split("."))

    if action == "major":
        major += 1 ;minor = 0 ; patch = 0
    elif action == "minor":
        minor += 1 ; patch = 0
    elif action == "patch":
        patch += 1
    else:
        print("Invalid action, choose major, minor or patch!")
        sys.exit(1)
    
    new_version = f"{major}.{minor}.{patch}"
    new_content = re.sub(
        r'__version__\s*=\s*["\']([^"\']+)["\']',
        f'__version__ = "{new_version}"',
        content
    )
    VERSION_FILE.write_text(new_content)
    run_git_command(["git", "add", str(VERSION_FILE)])
    
    # Git Commit: Create a standard version-bump commit
    commit_message = f"bump: release version {new_version}"
    run_git_command(["git", "commit", "-m", commit_message])
    print(f'  Created commit: "{commit_message}"')
    
    # Git Tag: Create a tag matching the new version (e.g., v1.1.0)
    tag_name = f"v{new_version}"
    run_git_command(["git", "tag", "-a", tag_name, "-m", f"Version {new_version}"])
    print(f'  ✓ Created local git tag: "{tag_name}"')

    # 5. Tell the user exactly what to do next
    print("\n All local steps complete! To push everything to GitHub/GitLab, run:")
    print(f"   git push origin main --tags")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python version.py [major | minor | patch]")
        sys.exit(1)
        
    user_action = sys.argv[1].lower()
    bump_version(user_action)