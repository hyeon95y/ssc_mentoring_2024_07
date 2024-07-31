# isort:imports-stdlib

# isort:import-localfolder


# isort:imports-thirdparty
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# isort:imports-firstparty


# isort:imports-stdlib

# isort:import-localfolder

# isort:imports-thirdparty
import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.impute import SimpleImputer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# isort:imports-firstparty


class DataPreprocessor:
    def __init__(self):
        self.pipeline = Pipeline(
            [
                ("feature_dropper", FeatureDropper()),
                ("imputer", SimpleImputer(strategy="mean")),
                ("scaler", StandardScaler()),
            ]
        )

    def preprocess(self, data: pd.DataFrame) -> pd.DataFrame:
        # First, define churn
        data = self.define_churn(data)

        # Separate features and target
        X = data.drop("churn", axis=1)
        y = data["churn"]

        # Fit and transform the data
        X_preprocessed = self.pipeline.fit_transform(X)

        # Get feature names after dropping
        feature_names = [
            col
            for col in X.columns
            if col not in self.pipeline.named_steps["feature_dropper"].features_to_drop
        ]

        # Convert back to DataFrame, preserving column names
        X_preprocessed_df = pd.DataFrame(
            X_preprocessed, columns=feature_names, index=X.index
        )

        # Add the target column back
        X_preprocessed_df["churn"] = y

        return X_preprocessed_df

    def define_churn(self, data: pd.DataFrame) -> pd.DataFrame:
        churn_features = [
            "purchase_count_month_lag0",
            "purchase_count_month_lag1",
            "purchase_count_month_lag2",
            "purchase_count_month_lag3",
        ]
        if all(feature in data.columns for feature in churn_features):
            data["churn"] = (data[churn_features].sum(axis=1) == 0).astype(int)
        return data


class FeatureDropper(BaseEstimator, TransformerMixin):
    def __init__(self):

        self.features_to_drop = [
            "purchase_count_month_lag0",
            "purchase_count_month_lag1",
            "purchase_count_month_lag2",
            "purchase_count_month_lag3",
            "purchase_revenue_month_lag0",
            "purchase_revenue_month_lag1",
            "purchase_revenue_month_lag2",
            "purchase_revenue_month_lag3",
            "customer_value_month_lag0",
            "customer_value_month_lag1",
            "customer_value_month_lag2",
            "customer_value_month_lag3",
            "target_event",
            "target_revenue",
            "target_customer_value",
            "target_customer_value_lag1",
            "target_actual_profit",
            "time_step",
            "purchase_count_month_ma3",
            "purchase_revenue_month_ma3",
            "customer_value_month_ma3",
            "session_count_month_ma3",
            "purchase_recency_min",
            "purchase_recency_max",
            "purchase_recency_mean",
            "session_recency_min",
            "session_recency_max",
            "session_recency_mean",
        ]

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return X.drop(columns=self.features_to_drop, errors="ignore")
