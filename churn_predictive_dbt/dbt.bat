@echo off
setlocal
"%~dp0.venv\Scripts\python.exe" "%~dp0dbt_wrapper.py" %*
endlocal
