# isort:imports-stdlib

# isort:import-localfolder


# isort:imports-thirdparty
import pandas as pd

# isort:imports-firstparty
from project_paths import DATA_PATH


class DataLoader:
    def __init__(self):
        pass

    def load_data(self) -> pd.DataFrame:
        file_name = "rees46_customer_model.csv"
        file_path = DATA_PATH / "raw" / file_name
        data = pd.read_csv(file_path)
        return data
