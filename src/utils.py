# isort:imports-stdlib

# isort:import-localfolder


# isort:imports-thirdparty
from sklearn.exceptions import ConvergenceWarning

# isort:imports-firstparty


# isort:imports-stdlib
import warnings

# isort:import-localfolder

# isort:imports-thirdparty
from sklearn.exceptions import ConvergenceWarning

# isort:imports-firstparty


def ignore_warnings():
    warnings.filterwarnings("ignore", category=ConvergenceWarning)
    warnings.filterwarnings("ignore", category=UserWarning)
    warnings.filterwarnings("ignore", category=FutureWarning)
