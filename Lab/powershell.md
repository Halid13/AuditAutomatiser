# Objective

Evaluate the ability to manipulate user data, automate management operations, and produce reports.
# Provided file: `pwsh_dataset.csv`

```csv
DisplayName,SamAccountName,Department,Enabled,LastLogonDate
Alice Dupont,adupont,Finance,TRUE,2025-10-15
Bob Martin,bmartin,IT,FALSE,2025-09-01
Claire Leroy,cleroy,HR,TRUE,2025-10-20
David Noel,dnoel,Finance,TRUE,2025-10-05
...
```

# Exercise

Write a PowerShell script named **`User_Audit.ps1`** that:
1. Reads the `users.csv` file.
2. Generates a report listing only **active** accounts whose last logon date is older than **10 days**.
3. Exports the result to a file named `Inactive_ActiveUsers.csv`.
4. Adds a `-Days` parameter allowing customization of the inactivity threshold (default: 10).
5. Displays in the console a summary like the example below:

```powershell
Total users: 4
Active but inactive >10 days: 2
Departments concerned: Finance, HR
```

6. The script should **generate the HTML body** and save it as `InactiveReport.html`; summarizing the inactive users per department.
    - The html body should contain a simple table or formatted text showing:
        - Department name
        - Number of inactive users
        - Usernames concerned
    - **Bonus**: Show how you would send the report via email using **SMTP**:

Example of expected structure (HTML or text):

```powershell
Department: Finance
Inactive users: 2 (adupont, dnoel)

Department: HR
Inactive users: 1 (cleroy)
```
