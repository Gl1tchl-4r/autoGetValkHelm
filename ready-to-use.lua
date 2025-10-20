_G.Configs = {
    ["Main"] = { -- ชื่อไอดีตัวหลัก ตัวกดสี ตัวเสกบอส มากสุด 1 ตัว
        ""
    },
    ["Farm"] = { -- ชื่อไอดีตัวฟาร์มบอส รอตีบอส
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
    }
}
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
loadstring(game:HttpGet("https://raw.githubusercontent.com/Gl1tchl-4r/autoGetValkHelm/refs/heads/main/scr.lua"))()
