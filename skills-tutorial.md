# How We Built a Custom Antigravity Skill

This guide documents the process we followed to create a custom **Code Style Checker** skill, based on the tutorial [Getting Started with Antigravity Skills](https://medium.com/google-cloud/tutorial-getting-started-with-antigravity-skills-864041811e0d).

## 1. Research & Discovery
The first step was to understand how Antigravity Skills work. We used the **Browser Tool** to read the provided Medium article and extracted the following key technical requirements:

*   **Location**: Skills must be placed in `.agent/skills/<skill-name>/` within the workspace.
*   **Definition**: A `SKILL.md` file is required, containing YAML frontmatter (for metadata) and Markdown instructions.
*   **Capabilities**: Skills can extend the agent's capabilities using standard scripts (Python, Bash, etc.) located in a `scripts/` subdirectory.

## 2. Planning the Skill
Based on the tutorial's examples (specifically the "Basic Router"), we decided to build a **Code Style Checker**.
*   **Goal**: Prevent `print()` statements in production code.
*   **Strategy**: Use a simple Python script to grep for violations, rather than a complex linter setup, to keep the example clear.

## 3. Implementation Process
We followed the tutorial's structure to create the skill.

### Step A: Directory Structure
We created the standard directory hierarchy recommended by the guide:
```text
.agent/skills/
└── code-style-checker/
    ├── SKILL.md
    └── scripts/
        └── check.py
```

### Step B: Defining the Skill (`SKILL.md`)
We wrote the `SKILL.md` to teach the agent *when* to use this tool.
*   **Trigger**: We set the description to match requests about "code review" or "bad practices".
*   **Instructions**: We instructed the agent to run our helper script and interpret the exit code (0 for success, 1 for failure).

### Step C: The Logic (`check.py`)
We implemented a lightweight Python script to scan for `print(` strings. This separates the logic from the prompt, making it deterministic and fast—a best practice highlighted in the tutorial.

## 4. Verification
To ensure the skill worked as described in the tutorial, we created test cases:
*   `bad.py`: Containing `print()`.
*   `good.py`: Containing `logging.info()`.

We then verified that the agent correctly identified `code-style-checker` as the right tool for the job and successfully flagged the violation.

## Conclusion
By following the pattern laid out in the "Getting Started" guide, we were able to quickly extend Antigravity's capabilities. The modular design allowed us to define a complex behavior (code style enforcement) using simple, standard files.
