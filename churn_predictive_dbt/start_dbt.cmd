@echo off
cd /d C:\dev\churn_predictive_repo\churn_predictive_dbt

call .venv\Scripts\activate.bat

echo.
echo Virtual environment activated.
echo You are now in:
cd
echo.
echo Use:
echo   dbt.bat --version
echo   dbt.bat run
echo   dbt.bat seed
echo   dbt.bat test
echo.
cmd /k cd /d C:\dev\churn_predictive_repo\churn_predictive_dbt
