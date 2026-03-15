-- [[ QLTZ SESSION MANAGER ]]
local CurrentJob = game.JobId
if _G.QLTZ_LastJob == CurrentJob and _G.QLTZ_Executed == true then
    return
end

-- Mark as executed for THIS server
_G.QLTZ_LastJob = CurrentJob
_G.QLTZ_Executed = true

-- [[ 1. IMMEDIATE PERFORMANCE NUKE (ANTI-LAG) ]]
local function Optimize()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualityLevel.QualityLevel1
        if sethiddenproperty then sethiddenproperty(game:GetService("Lighting"), "Technology", Enum.Technology.Compatibility) end
    end)

    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    for _, v in ipairs(Lighting:GetChildren()) do
        if not v:IsA("SunRaysEffect") then pcall(function() v:Destroy() end) end
    end

    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("PostEffect") or v:IsA("Explosion") then
            pcall(function() v:Destroy() end)
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
            v.Enabled = false
        end
    end
    
    pcall(function() workspace:FindFirstChildOfClass("Terrain"):Clear() end)
end
task.spawn(Optimize)

repeat task.wait() until game:IsLoaded()

-- [[ CONFIGURATION ]]
local HttpService = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PlaceID = game.PlaceId

-- [[ AUTO-LOAD EXTERNAL ]]
local SCRIPT_URL = "https://pastebin.com/raw/jX8TBuSh" 
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet(SCRIPT_URL))()
    end)
end)

-- [[ OBFUSCATION CONFIGURATION ]]
local SITE_API = "https://qltz-notifier.onrender.com"
local JOIN_BASE_URL = "https://qltz-notifier.onrender.com/join?jobid="

-- Webhooks (With Links)
local WEBHOOKS = {
    [100e6] = "https://discord.com/api/webhooks/1466219731223842821/lH83Yf6nmMUMTaV2dRmdfPtpwIrVsIun9e1oSDMoU3sh4btncOAJrmxzXPEpbkNIQkUt", 
    [50e6]  = "https://discord.com/api/webhooks/1466646344197341207/fYeGnaxUuTZnJlHRn_XPLJb2sVpAVbxNpJQDqx2oAF4B0rmuW70BS5EB4gRPq4qAoK_z", 
    [10e6]  = "https://discord.com/api/webhooks/1466183856355803167/6d72-gPig19XdKeak7JYIxJnrKuOOcV6qfRSHk3dDF8XIsQQG3UayuNMnFsXdWEa0I5P"  
}

local LINKLESS_WEBHOOKS = {
    [100e6] = "https://discord.com/api/webhooks/1479520099961540719/M2jO7BC2BGhg900Im8L82OhdueAOfbPP-qFGsSGH4UWu-K40FVD87LKL_nGYz5J3hNdk",
    [50e6]  = "https://discord.com/api/webhooks/1479520475779432449/gM800MEY9dD44vZWoxoCjCP93NJmXkPyrb4yrrAPR3eCVhfRK3ndLFHfMS0YTxWj4GGq",
    [10e6]  = "https://discord.com/api/webhooks/1479520615823179887/rLevCP4ulp-b1-4U8NS6uBljznEedaOuGkpII8aSAAZbfbZGRXZSxv6yGhvwo_rse3kc"
}

local LOG_WEBHOOK = "https://discord.com/api/webhooks/1479282077173157919/_mAtHvjaQu9_G1M4YwI0Ei19-gDRdh_c1EquMJFBuphENRfIb5IBRw2tHHqztUgQBUWn"

-- [[ UI STATUS ]]
local sg = Instance.new("ScreenGui")
pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui") end)

local status = Instance.new("TextLabel", sg)
status.Size = UDim2.new(1, 0, 0, 35)
status.BackgroundTransparency = 0.4
status.BackgroundColor3 = Color3.new(0,0,0)
status.TextColor3 = Color3.fromRGB(0, 255, 150)
status.TextSize = 18
status.Font = Enum.Font.Code
status.Text = "QLTZ: SCANNING & HOPPING..."

-- [[ 2. IMAGES DATABASE ]]
local BRAINROT_IMAGES = {
    -- New Brainrots
    ["Patteo"] = "",
    ["Clovkur Kurkur"] = "",
    ["La Vacca Lepre Lepreino"] = "",
    ["Luck Luck Luck Sahur"] = "",
    ["Noo mi gold"] = "",
    ["Snailo Clovero"] = "",
    ["Gold gold gold"] = "",
    ["Fortunu and Cashuru"] = "",
    -- Original Database
    ["DJ Panda"] = "",
    ["Celestial Pegasus"] = "",
    ["Tang Tang Keletang"] = "https://cdn.discordapp.com/attachments/1446262217048850515/1453828830035709993/latest.png",
    ["Los Mobilis"] = "https://static.wikia.nocookie.net/stealabr/images/2/27/Losmobil.png",
    ["Spaghetti Tualetti"] = "https://static.wikia.nocookie.net/stealabr/images/b/b8/Spaghettitualetti.png",
    ["La Taco Combinasion"] = "https://static.wikia.nocookie.net/stealabr/images/8/84/Latacocombi.png",
    ["Esok Sekolah"] = "https://static.wikia.nocookie.net/stealabr/images/0/09/Esoksekolahwnovfx.png",
    ["La Secret Combinasion"] = "https://static.wikia.nocookie.net/stealabr/images/f/f2/Lasecretcombinasion.png",
    ["Dragon Cannelloni"] = "https://static.wikia.nocookie.net/stealabr/images/0/02/Dragoncanneloni.png",
    ["Los Spaghettis"] = "https://static.wikia.nocookie.net/stealabr/images/d/db/LosSpaghettis.png",
    ["Fragrama and Chocrama"] = "https://static.wikia.nocookie.net/stealabr/images/5/56/Fragrama.png",
    ["Los Puggies"] = "https://static.wikia.nocookie.net/stealabr/images/c/c8/LosPuggies2.png",
    ["Swaggy Bros"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246155672584242/Swaggy_Bros.png",
    ["Capitano Moby"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043577292263576/Moby.png",
    ["Garama and Madundung"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043416549490738/Garamadundung.png",
    ["La Spooky Grande"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043609659445299/Spooky_Grande.png",
    ["Eviledon"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043414754332742/Eviledonn.png",
    ["Orcaledon"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246084461432914/Orcaledon.png",
    ["Ketchuru and Musturu"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043475492180028/Ketchuru.png",
    ["Los Candies"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246009387712624/LosCandies.png",
    ["W or L"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043669889908918/Win_Or_Lose.png",
    ["Mieteteira Bicicleteira"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043557419651272/mieteteira.png",
    ["Ketupat Kepat"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043478587703327/KetupatKepat.png",
    ["La Ginger Sekolah"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245960284999833/La_ginger_Sekolah.png",
    ["Santa Hotspot"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246121635811511/Santa_Hotspot.png",
    ["Los 25"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245996267802798/Los_25.png",
    ["Los Cucarachas"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245999883550791/Los_Cucarachas.png",
    ["Chimnino"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245848209002753/Chimnino.png",
    ["Triplito Tralaleritos"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246191927885946/Triplito_Tralaleritos.png",
    ["Naughty Naughty"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246076337324303/naughty.png",
    ["Los Burritos"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246005147402330/LosBurritos.png",
    ["Quesadilla Crocodila"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043600969105428/QuesadillaCrocodilla.png",
    ["Pot Hotspot"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246088752336936/Pot_Hotspot.png",
    ["Los Jobcitos"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043525932880067/LosJobcitos.png",
    ["Chicleteira Bicicleteira"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043371708190872/Chicleteira.png",
    ["La Grande Combinasion"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043441283567687/grandecom.png",
    ["Los Combinasionas"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043401420898314/combinasionas.png",
    ["La Extinct Grande"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245957604708547/La_Extinct_Grande.png",
    ["Los 67"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043517699461180/Los-67.png",
    ["Chicleteirina Bicicleteirina"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245824574226533/Chicleteirina_Bicicleteirina.png",
    ["Los Quesadillas"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043550444388373/LosQuesadillas.png",
    ["67"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245809629794455/67.png",
    ["Chicleteira Noelteira"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043581427712153/Noel.png",
    ["Ho Ho Ho Sahur"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043452490485852/HoHoHoSahur.png",
    ["Money Money Puggy"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246074244370665/Money_money_puggy.png",
    ["Horegini Boom"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043448254238856/Hboom.png",
    ["Los Chicleteiras"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043520174096546/Los_chicleterrias.png",
    ["Trickolino"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043665812918362/Trickortreat.png",
    ["Tacorita Bicicleta"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043638290022571/tacoritabici.png",
    ["Graipuss Medussi"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043438884163714/Graipuss.png",
    ["Meowl"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/10/Steal-A-Brainrot-Wiki-Meowl-Icon.png",
    ["Strawberry Elephant"] = "https://static.wikia.nocookie.net/stealabr/images/5/58/Strawberryelephant.png",
    ["Los Nooo My Hotspotsitos"] = "https://cdn.discordapp.com/attachments/1414882878101258281/1466487732120584254/Los_Nooo_My_Hotspotsitos.png",
    ["Burrito Bandito"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043364330536990/burritoBandito.png",
    ["Los Tacoritas"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043552742736024/lostacoritas.png",
    ["Gobblino Uniciclino"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245894732091527/Gobblino_Uniciclino.png",
    ["Lavadorito Spinito"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451245972813385748/Lavadorito_Spinito.png",
    ["Las Tralaleritas"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043493665968178/LasTralaleritas.png",
    ["Noo my Present"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1451246080275775700/Noo_my_Present.png",
    ["Swag Soda"] = "https://cdn.discordapp.com/attachments/1446260591554597038/1454199242062172233/2Q.png",
    ["La Cucaracha"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/09/La-Cucaracha-Icon-150x150.png",
    ["Nuclearo Dinossauro"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043583256297532/nuclearo.png",
    ["Chipso and Queso"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043397163683840/Chipsoqueso.png",
    ["Spooky and Pumpky"] = "https://cdn.discordapp.com/attachments/1445610535612580040/1447043629272141937/Spookypumpky.png",
    ["Cooki and Milki"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/11/Steal-a-Brainrot-Wiki-Cooki-and-Milki-Icon.png",
    ["Burguro And Fryuro"] = "https://static.wikia.nocookie.net/stealabr/images/6/65/Burguro-And-Fryuro.png",
    ["Tictac Sahur"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/09/Tictac-Sahur-Icon.png",
    ["Los Spooky Combinasionas"] = "https://static.wikia.nocookie.net/stealabr/images/8/8a/Lospookycombi.png",
    ["Los Bros"] = "https://static.wikia.nocookie.net/stealabr/images/5/53/BROOOOOOOO.png",
    ["Tuff Toucan"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2026/01/Tuff-Toucan-Icon.png",
    ["Las Sis"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/09/Las-Sis-1.png",
    ["Skibidi Toilet"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/12/Skibidi-Toilet-Icon.png",
    ["Bacuru and Egguru"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2026/01/Steal-A-Brainrot-Wiki-Bacuru-and-Egguru-Icon-.png",
    ["Tralaledon"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/09/Tralalaledon-1.png",
    ["Los Ay Mi Gatitos"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2026/01/Los-Mi-Gatitos-Icon.png",
    ["Ay Mi Gatito"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2026/01/Steal-A-Brainrot-Ay-Mi-Gatito-icon.png",
    ["Los Trios"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2026/01/Steal-A-Brainrot-Wiki-Los-Trios-Icon-.png",
    ["Hydra Dragon Cannelloni"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2026/01/Steal-A-Brainrot-Wiki-Hydra-Dragon-Icon-.png",
    ["Mariachi Corazoni"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/11/Mariachi-Corazoni-Icon.png",
    ["Perrito Burrito"] = "https://steal-a-brainrot.wiki/wp-content/uploads/2025/10/Steal-a-Brainrot-Wiki-Perrito-Burrito-Icon.png",
    ["Spinny Hammy"] = "https://static.wikia.nocookie.net/stealabr/images/7/7d/SpinnyHammy.png",
    ["Chill Puppy"] = "https://static.wikia.nocookie.net/stealabr/images/e/e0/Chill_Puppy.png",
    ["Mi Gatito"] = "https://static.wikia.nocookie.net/stealabr/images/0/07/AyMiGattitoMeow.png",
    ["Love Love Love Sahur"] = "https://static.wikia.nocookie.net/stealabr/images/5/50/PLEASE%2C_FEEL_THE_LOVE.png",
    ["Cupid Hotspot"] = "https://static.wikia.nocookie.net/stealabr/images/1/1f/Pot_Cupid.png",
    ["Noo my Heart"] = "https://static.wikia.nocookie.net/stealabr/images/7/75/NooMyLoveheart.png",
    ["Chicleteira Cupideira"] = "https://static.wikia.nocookie.net/stealabr/images/6/6f/Chicleteira_Cupideira.png",
    ["Arcadopus"] = "https://static.wikia.nocookie.net/stealabr/images/4/4a/ArcadopusYuh.png"
}

local TargetList = {}
for name, _ in pairs(BRAINROT_IMAGES) do table.insert(TargetList, name) end
local extra = {"Tacorillo Crocodillo", "Nacho Spyder", "Elefanto Frigo", "Signore Carapace", "Tirilialika Tirilikalako", "Antonio", "Los Amigos", "La Food Combinasion", "Sammyni Fattini", "Los Sekolahs", "La Romantic Grande", "Luv Luv Luv", "Karkerheart Luvkur", "Rosetti Tualetti", "Rosey and Teddy", "1x1x1x1", "67", "Agarrini la Palini", "Alessio", "Anpali Babel", "Aquanaut", "Ballerina Peppermintina", "Ballerino Lololo", "Bambu Bambu Sahur", "Belula Beluga", "Bisonte Giuppitere", "Blackhole Goat", "Boba Panda", "Boatito Auratito", "Bombardini Tortinii", "Brasilini Berimbini", "Brr es Teh Patipum", "Buho de Noelo", "Bulbito Bandito Traktorito", "Cacasito Satalito", "Capi Taco", "Cappuccino Clownino", "Celularcini Viciosini", "Chachechi", "Chihuanini Taconini", "Chillin Chili", "Chrismasmamat", "Cocoa Assassino", "Cocofanto Elefanto", "Corn Corn Corn Sahur", "Crabbo rural", "Cuadramat and Pakrahmatmamat", "Dolphini Jetskini", "Dug dug dug", "Dul Dul Dul", "Espresso Signora", "Extinct Ballerina", "Extinct Matteo", "Extinct Tralalero", "Fishino Clownino", "Fragola La La La", "Frankentteo", "Frio Ninja", "Gattatino Neonino", "Gattatino Nyanino", "Gattito Tacoto", "Ginger Cisterna", "Ginger Globo", "Girafa Celestre", "Granchiello Spiritell", "Guerriro Digitale", "Guest 666", "Headless Horseman", "Job Job Job Sahur", "Karker Sahur", "Karkerkar Kurkur", "Ketupat Bros", "Krupuk Pagi Pagi", "La Casa Boo", "La Karkerkar Combinasion", "La Sahur Combinasion", "La Supreme Combinasion", "La Vacca Jacko Linterino", "La Vacca Saturno Saturnita", "Las Capuchinas", "Las Vaquitas Saturnitas", "Los Bombinitos", "Los Chihuaninis", "Los Crocodillitos", "Los Gattitos", "Los Hotspotsitos", "Los Karkeritos", "Los Matteos", "Los Orcalitos", "Los Planitos", "Los Primos", "Los Spyderinis", "Los Tipi Tacos", "Los Tralaleritos", "Los Tortus", "Los Tungtungtungcitos", "Mastodontico Telepiedone", "Matteo", "Money Money Man", "Money Money Puggy", "Mummy Ambalabu", "Noo La Polizia", "Noo My Hotspot", "Noo my Candy", "Noo my examine", "Odin Din Din Dun", "Orcalera Orcala", "Orcalita Orcala", "Pakrahmatmamat", "Pakrahmatmatina", "Pandanini Frostini", "Piccione Machina", "Piccionetta Machina", "Pirulitoita Bicicleteira", "Pop Pop Sahur", "Pot Pumpkin", "Pumpkini Spyderini", "Quesadillo Vampiro", "Rang Ring Bus", "Sammyni Spyderini", "Skull Skull Skull", "Snailenzo", "Squalanana", "Statutino Libertino", "Tantang Keletang", "Tartaruga Cisterna", "Telemorte", "Tentacolo Technical", "Tigroligre Frutonni", "Tipi Topi Taco", "To To To Sahur", "Tootini Shrimpini", "Torrtuginni Dragonfrutini", "Tractoro Dinosauro", "Tralaledon", "Tralalero Tralala", "Tralalita Tralala", "Trenostruzzo Turbo 3000", "Trenostruzzo Turbo 4000", "Trippi Troppi Troppa Trippa", "Tukanno Bananno", "Tung Tung Tung Sahur", "Unclito Samito", "Urubini Flamenguini", "Vampira Cappuccina", "Vulturino Skeletono", "Yeti Claus", "Yess my examine", "Zombie Tralala", "Secret Lucky Block", "GOAT", "Cerberus", "La Vacca Prese Presente", "Reindeer Tralala", "Rocco Disco", "Santteo", "Giftini Spyderini", "Please my Present", "Bunnyman", "Coffin Tung Tung Tung Sahur", "List List Sahur", "Bunito Bunito Spinito", "Ho Ho Ho Sahur", "Brunito Marsito", "Donkeyturbo Express", "Los 25", "Los Jolly Combinasionas", "Money Money Reindeer", "La Jolly Grande", "Lovin Rose", "Swaggy Bros", "Jolly Jolly Sahur", "Festive 67", "Ginger Gerat", "La Secret Combinasion", "Reinito Sleighito", "Popcuru and Fizzuru", "Dragon Gingerini", "Griffin", "Holy Arepa", "Pengolino Nuvoletto", "Gato Celesto", "Buho del Cielo", "Seraphino Gruyero", "Harpuccino", "Berenjello Angello", "Divino Platypio", "Astrolero Cervalero", "Dumborino Miracello", "Paradiso Axolottino", "Cigno Fulgoro"}
for _, v in ipairs(extra) do table.insert(TargetList, v) end
local Targets = {} for _, n in ipairs(TargetList) do Targets[n] = true end

-- [[ 3. UTILS & OBFUSCATION ]]
local function parseValue(text)
    if not text then return 0 end
    local clean = text:gsub("[^%d%.TBMK]", "") 
    local mult = 1
    if clean:find("T") then mult = 1e12 elseif clean:find("B") then mult = 1e9 elseif clean:find("M") then mult = 1e6 elseif clean:find("K") then mult = 1e3 end
    local numPart = clean:gsub("[TBMK]", "")
    return (tonumber(numPart) or 0) * mult
end

local function getCST()
    local timeUTC = os.time()
    local timeCST = timeUTC - (6 * 3600)
    return os.date("%X", timeCST)
end

local function obter_job_id_ofuscado(job_id_uuid)
    local success, response = pcall(function()
        return game:HttpGet(SITE_API .. "/api/obfuscate?job_id=" .. job_id_uuid)
    end)
    if success and response and response ~= "" then
        local json_success, data = pcall(function() return HttpService:JSONDecode(response) end)
        if json_success and data.success then return data.obfuscated_job_id end
    end
    return nil
end

local AllIDs = {}
pcall(function()
    if isfile and isfile("NotSameServers.json") then
        local saved = readfile("NotSameServers.json")
        if saved then AllIDs = HttpService:JSONDecode(saved) end
    end
end)

local function SaveID(id)
    table.insert(AllIDs, id)
    if #AllIDs > 150 then table.remove(AllIDs, 1) end
    pcall(function() writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs)) end)
end

-- [[ 4. SCANNER ]]
local function ScanAndHop()
    local sortedFindings = {[100e6] = {}, [50e6] = {}, [10e6] = {}}
    local hasTargets = false

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("TextLabel") and Targets[v.Text] then
            local parent = v.Parent
            local gen = parent and parent:FindFirstChild("Generation") or (parent and parent.Parent and parent.Parent:FindFirstChild("Generation"))
            if gen and gen:IsA("TextLabel") then
                local val = parseValue(gen.Text)
                local data = {Name = v.Text, IncomeText = gen.Text, Value = val}
                
                if val >= 100e6 then table.insert(sortedFindings[100e6], data); hasTargets = true
                elseif val >= 50e6 then table.insert(sortedFindings[50e6], data); hasTargets = true
                elseif val >= 10e6 then table.insert(sortedFindings[10e6], data); hasTargets = true end
            end
        end
    end

    if hasTargets then
        local raw_id = tostring(game.JobId)
        local masked_id = obter_job_id_ofuscado(raw_id)
        local final_id = masked_id or raw_id
        local final_link = JOIN_BASE_URL .. final_id

        task.spawn(function()
            local results = {}
            for _, tResults in pairs(sortedFindings) do for _, r in ipairs(tResults) do table.insert(results, r) end end
            table.sort(results, function(a, b) return a.Value > b.Value end)
            
            local listText = "**Brainrots found:**\n"
            for i, res in ipairs(results) do if i <= 15 then listText = listText .. "🔥 " .. res.Name .. " - " .. res.IncomeText .. "\n" end end

            request({
                Url = LOG_WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({ embeds = {{
                    ["title"] = "QLTZ Notifier Full Log", ["color"] = 16711680,
                    ["description"] = listText, ["thumbnail"] = { ["url"] = BRAINROT_IMAGES[results[1].Name] or "" },
                    ["fields"] = {
                        {["name"] = "👤 User Who Found It:", ["value"] = "`" .. LP.Name .. "`"},
                        {["name"] = "🆔 Raw Job ID", ["value"] = "```" .. raw_id .. "```"},
                        {["name"] = "📊 Server Info", ["value"] = "`" .. #Players:GetPlayers() .. "/8 Players`"}, 
                        {["name"] = "🔗 Join Server", ["value"] = "[CLICK TO JOIN](" .. final_link .. ")"}},
                    ["footer"] = {["text"] = "QLTZ Notifier 🔥 | " .. getCST() .. " CST"}
                }} })
            })
        end)

        for tier, results in pairs(sortedFindings) do
            if #results > 0 then
                table.sort(results, function(a, b) return a.Value > b.Value end)
                local listText = "**Brainrots found:**\n"
                for i, res in ipairs(results) do if i <= 15 then listText = listText .. "🔥 " .. res.Name .. " - " .. res.IncomeText .. "\n" end end
                local embedColor = (tier == 100e6 and 10181046) or (tier == 50e6 and 16753920) or 65280
                
                task.spawn(function()
                    request({
                        Url = WEBHOOKS[tier], Method = "POST", Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({ embeds = {{
                            ["title"] = "QLTZ Notifier", ["color"] = embedColor,
                            ["description"] = listText, ["thumbnail"] = { ["url"] = BRAINROT_IMAGES[results[1].Name] or "" },
                            ["fields"] = {
                                {["name"] = "👤 User Who Found It:", ["value"] = "`" .. LP.Name .. "`"},
                                {["name"] = "📊 Server Info", ["value"] = "`" .. #Players:GetPlayers() .. "/8 Players`"}, 
                                {["name"] = "🔗 Join Server", ["value"] = "[CLICK TO JOIN](" .. final_link .. ")"}},
                            ["footer"] = {["text"] = "QLTZ Notifier 🔥 | " .. getCST() .. " CST"}
                        }} })
                    })
                end)

                task.spawn(function()
                    request({
                        Url = LINKLESS_WEBHOOKS[tier], Method = "POST", Headers = {["Content-Type"] = "application/json"},
                        Body = HttpService:JSONEncode({ embeds = {{
                            ["title"] = "QLTZ Notifier", ["color"] = embedColor,
                            ["description"] = listText, ["thumbnail"] = { ["url"] = BRAINROT_IMAGES[results[1].Name] or "" },
                            ["fields"] = {
                                {["name"] = "👤 User Who Found It:", ["value"] = "`" .. LP.Name .. "`"},
                                {["name"] = "📊 Server Info", ["value"] = "`" .. #Players:GetPlayers() .. "/8 Players`"}
                            },
                            ["footer"] = {["text"] = "QLTZ Notifier 🔥 | " .. getCST() .. " CST"}
                        }} })
                    })
                end)
            end
        end
    end
end

-- [[ 5. FAST HOPPER ENGINE (RANDOM 2-7 PLAYERS) ]]
local cursor = ""
local retryCount = 0

local function TPReturner()
    retryCount = retryCount + 1
    local success, Site = pcall(function()
        local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100'
        if cursor ~= "" then url = url .. '&cursor=' .. cursor end
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
    if not success or not Site or not Site.data then task.wait(1) cursor = "" return end
    cursor = (Site.nextPageCursor and Site.nextPageCursor ~= "null") and Site.nextPageCursor or ""

    local validServers = {}
    for _, v in pairs(Site.data) do
        local ID = tostring(v.id)
        local playing = tonumber(v.playing)
        
        if ID ~= game.JobId and playing and playing >= 2 and playing <= 7 then
            local isNew = true
            for _, Existing in pairs(AllIDs) do if ID == Existing then isNew = false break end end
            if isNew then table.insert(validServers, ID) end
        end
    end

    if #validServers > 0 then
        local randomID = validServers[math.random(1, #validServers)]
        SaveID(randomID)
        
        local q_code = 'loadstring(game:HttpGet("'..SCRIPT_URL..'"))()'
        local q_on_tp = (queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
        if q_on_tp then pcall(function() q_on_tp(q_code) end) end

        status.Text = "QLTZ: HOPPING TO NEXT SERVER..."
        TPS:TeleportToPlaceInstance(PlaceID, randomID, LP)
        return 
    end

    if retryCount >= 5 then
        AllIDs = {}
        pcall(function() writefile("NotSameServers.json", "[]") end)
        retryCount = 0
        cursor = ""
    end
end

-- [[ 6. EXECUTE ]]
ScanAndHop()
while true do 
    TPReturner() 
    task.wait(0)
end
