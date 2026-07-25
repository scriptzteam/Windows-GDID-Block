# Windows-GDID-Block

> ⚠️ **Honest disclaimer up front:** this tool does **not** erase your GDID and does
> **not** make you anonymous. The GDID lives on Microsoft's servers, tied to your
> Microsoft Account, the moment you sign in. `Windows-GDID-Block` stops your machine from
> *re-registering and reporting* it — it cannot undo what Microsoft already has. For
> real privacy on sensitive work, the only reliable answer is NOT to depend on Windows.

Run it:

Open an Elevated (Administrator) PowerShell window and run:  
```irm https://raw.githubusercontent.com/scriptzteam/Windows-GDID-Block/refs/heads/main/gdid-block.ps1 | iex```

If the command above gives you a script block or execution policy error, wrap it like this instead:  
```powershell -NoProfile -ExecutionPolicy Bypass -Command "https://raw.githubusercontent.com/scriptzteam/Windows-GDID-Block/refs/heads/main/gdid-block.ps1 | iex"```

or

```Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/scriptzteam/Windows-GDID-Block/refs/heads/main/gdid-block.ps1 | iex```
