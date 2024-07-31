# isort:maintain_block
import sys  # isort: skip
from pathlib import Path  # isort: skip
import os  # isort: skip

PATH_PROJECT_FOLDER = "/home/repos/ssc_mentoring_2024_07"  # NOQA: E402

if os.path.exists(PATH_PROJECT_FOLDER):  # NOQA: E402
    path_project_folder = PATH_PROJECT_FOLDER  # NOQA: E402
else:  # NOQA: E402
    raise FileNotFoundError("path_project_folder not found")  # NOQA: E402

PROJECT_PATH = Path(path_project_folder)  # NOQA: E402
SRC_PATH = PROJECT_PATH / "src"  # NOQA: E402\

sys.path.append(str(SRC_PATH))  # NOQA: E402
# isort:end_maintain_block

STARTUP_SCRIPT_DONE = True
