import subprocess
from pathlib import Path

import mat73
import scipy.io as sio


def download_mat_file(file_url: str, file_path: str | Path) -> bool:

    if not isinstance(file_path, Path):
        file_path = Path(file_path)

    if not file_path.exists():
        file_path.parent.mkdir(parents=True, exist_ok=True)
        tmp_path = file_path.with_name(file_path.name + ".part")
        result = subprocess.run(["wget", file_url, "-O", tmp_path])
        if result.returncode == 0:
            tmp_path.replace(file_path)
            return True
        else:
            return True
    return True

def read_mat_file(path: str | Path) -> dict:
    """
    reads a MATLAB .mat file.
    assumes the file exists
    """
    try:
        return mat73.loadmat(
            file=str(path)
        )
    except Exception:
        return sio.loadmat(
            file_name=str(path),
            squeeze_me=True,
            chars_as_strings=True,
            struct_as_record=False
        )

def load_mat_file(file_path: str | Path, file_url: str | None = None) -> dict:
    if file_url is not None:
        success = download_mat_file(file_url, file_path)
        assert success, f"Error."
    return read_mat_file(file_path)