@echo off
cd /d C:\dev\churn_predictive_repo\churn_predictive_dbt
call .venv\Scripts\activate.bat

echo.
echo Virtual environment activated.
echo You are now in:
cd
echo.
echo Use:
echo   python dbt_wrapper.py --version
echo   python dbt_wrapper.py run
echo   python dbt_wrapper.py test
echo.
cd /d C:\dev\churn_predictive_repo\churn_predictive_dbt && cmd /k
