@echo off
setlocal
title Fake Games - 209 jogos x 24h = ~5.000h

set "BASE=%TEMP%\fake_games_horas"
set "FAKE=%BASE%\fake.exe"
set "CS=%BASE%\fake.cs"
if not exist "%BASE%" mkdir "%BASE%"

echo 1 = Iniciar
echo 2 = Parar todos os jogos falsos abertos
set /p OP=Opcao [1]: 
if "%OP%"=="2" goto :parar

rem fecha jogos falsos de uma execucao anterior antes de recompilar
call :matar

set "CSC=%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if not exist "%CSC%" set "CSC=%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if not exist "%CSC%" (
    echo Nao achei o csc.exe do .NET Framework 4.
    pause
    exit /b
)

rem Programinha com janela que fecha sozinho depois de X horas (aceita decimal, ex: 45.5)
echo using System; > "%CS%"
echo using System.Globalization; >> "%CS%"
echo using System.Windows.Forms; >> "%CS%"
echo class P { >> "%CS%"
echo   [STAThread] static void Main(string[] a) { >> "%CS%"
echo     double h = 1; >> "%CS%"
echo     try { h = double.Parse(a[0].Replace(",", "."), CultureInfo.InvariantCulture); } catch {} >> "%CS%"
echo     DateTime fim = DateTime.Now.AddHours(h); >> "%CS%"
echo     Form f = new Form(); >> "%CS%"
echo     try { f.Text = a[1]; } catch { f.Text = "Fake game"; } >> "%CS%"
echo     f.Width = 420; f.Height = 100; >> "%CS%"
echo     f.WindowState = FormWindowState.Minimized; >> "%CS%"
echo     Timer t = new Timer(); >> "%CS%"
echo     t.Interval = 30000; >> "%CS%"
echo     t.Tick += delegate { if (DateTime.Now.CompareTo(fim) ^>= 0) f.Close(); }; >> "%CS%"
echo     t.Start(); >> "%CS%"
echo     Application.Run(f); >> "%CS%"
echo   } >> "%CS%"
echo } >> "%CS%"

if exist "%FAKE%" del /f /q "%FAKE%" >nul 2>&1
"%CSC%" /nologo /target:winexe /out:"%FAKE%" /r:System.Windows.Forms.dll "%CS%"
if not exist "%FAKE%" (
    echo Falha ao compilar. Rode de novo e escolha a opcao 2 antes.
    pause
    exit /b
)

for /f %%c in ('findstr /b /c:"::G|" "%~f0" ^| find /c /v ""') do set MAX=%%c

echo.
echo Quantos jogos abrir ao mesmo tempo? (1 a %MAX%)
set /p QTD=Jogos [%MAX%]: 
if "%QTD%"=="" set QTD=%MAX%
echo.
echo Quantas horas cada um fica aberto? (pode usar decimal, ex: 45.5)
set /p HORAS=Horas [24]: 
if "%HORAS%"=="" set HORAS=24

echo.
echo ------------------------------------------------------------
echo  %QTD% jogos x %HORAS%h = total registrado aproximado
echo  Tempo real: %HORAS% hora(s). Deixe o PC e o Discord ligados.
echo  Desative suspensao/hibernacao do Windows enquanto roda.
echo ------------------------------------------------------------
echo.

set N=0
for /f "tokens=2,3,4 delims=|" %%a in ('findstr /b /c:"::G|" "%~f0"') do (
    set "GNAME=%%b"
    set "GEXE=%%c"
    call :abrir
)

echo.
echo %N% jogos abertos (minimizados). Eles fecham sozinhos em %HORAS%h.
echo Pode fechar esta janela. Para parar antes, rode o .bat de novo e escolha 2.
echo.
pause
exit /b

:abrir
if %N% GEQ %QTD% goto :eof
set /a N+=1
set "REL=%GEXE:/=\%"
set "DEST=%BASE%\jogos\%N%\%REL%"
for %%F in ("%DEST%") do if not exist "%%~dpF" mkdir "%%~dpF"
copy /y "%FAKE%" "%DEST%" >nul 2>&1
echo [%N%/%QTD%] Aberto: %GNAME%
start "" "%DEST%" %HORAS% "%GNAME%"
rem pequena pausa para o Discord registrar cada um
timeout /t 2 /nobreak >nul
goto :eof


:parar
call :matar
echo Jogos falsos fechados.
rmdir /s /q "%BASE%\jogos" >nul 2>&1
pause
exit /b

:matar
powershell -NoProfile -Command "Get-Process | Where-Object { $_.Path -like ($env:TEMP + '\fake_games_horas\*') } | Stop-Process -Force" >nul 2>&1
timeout /t 1 /nobreak >nul
goto :eof

rem ---- Lista de jogos (id do Discord | nome | executavel) ----
::G|356875221078245376|Overwatch|overwatch.exe
::G|356875762940379136|World of Warcraft|_retail_/wow-64.exe
::G|356875890958925834|Hearthstone|hearthstone.exe
::G|356875988589740042|Dota 2|dota2.exe
::G|356876590342340608|Rainbow Six Siege|rainbowsix.exe
::G|356877880938070016|Rocket League|rocketleague.exe
::G|356878860190613504|Heroes of the Storm|heroesofthestorm_x64.exe
::G|356879032584896512|Garry's Mod|hl2.exe
::G|356887282982191114|ARK: Survival Evolved|shootergame.exe
::G|356888453796986880|Path of Exile|path of exile/pathofexile_x64steam.exe
::G|356888577310851072|Team Fortress 2|hl2tf.exe
::G|356889262362329098|FINAL FANTASY XIV ONLINE|ffxiv_dx11.exe
::G|356942674672091136|Geometry Dash|geometrydash.exe
::G|356944273133928458|Brawlhalla|brawlhalla.exe
::G|356953358952562688|The Walking Dead|walkingdead101.exe
::G|356953520278339584|Sonic Mania|sonicmania.exe
::G|356954034701205504|Golf With Your Friends|golf with your friends.exe
::G|356954111901433856|Cities: Skylines|cities.exe
::G|356954176338788352|Arma 3|arma3.exe
::G|356954277803065354|Left 4 Dead 2|left4dead2.exe
::G|357606832899883008|RuneScape|runescape.exe
::G|357607133254254632|Dead by Daylight|deadbydaylight-win64-shipping.exe
::G|357607478105604096|War Thunder|aces.exe
::G|358417041981571082|Battlefield 1|bf1.exe
::G|358420454764969994|The Binding of Isaac: Rebirth|isaac-ng.exe
::G|358421573071536128|HIVESWAP: Act 1|hiveswap-act1.exe
::G|358421669603311616|Hearts of Iron IV|hoi4.exe
::G|358421781398421514|Blade Soul|playbns.exe
::G|358421904601776138|Sid Meier's Civilization V|civilizationv_dx11.exe
::G|358422012990849024|SMITE|smiteeac.exe
::G|358422126602223616|Factorio|factorio.exe
::G|358425751197974528|Diablo III|diablo iii.exe
::G|358425800766128128|StarCraft II: Battle Chest|sc2.exe
::G|359507724196773888|The Elder Scrolls V: Skyrim|tesv.exe
::G|359507798930751488|Tom Clancy's The Division|the division.exe
::G|359508342571401216|ShellShock Live|shellshocklive.exe
::G|359508404034600990|Space Engineers|spaceengineers.exe
::G|359508941782122496|Portal 2|portal2.exe
::G|359509007423242240|The Sims 4|ts4_x64.exe
::G|359509332490059776|Call of Duty: Black Ops III|blackops3.exe
::G|359509387670192128|Stardew Valley|stardew valley.exe
::G|359509500199436288|DARK SOULS III|darksoulsiii.exe
::G|359509759642042378|Fallout 4|fallout4.exe
::G|359509858728542208|Fallout: New Vegas|falloutnv.exe
::G|359510095811444736|MapleStory|maplestory.exe
::G|359510249486417920|The Witcher 3: Wild Hunt|witcher3.exe
::G|359510373361254400|Half-Life 2|hl2hl2.exe
::G|359510680459673610|Battlefield 4|bf4.exe
::G|359510740878491658|XCOM 2|xcom2.exe
::G|359511228445491200|Guild Wars 2|gw2.exe
::G|359801269008859136|The Elder Scrolls V: Skyrim - Special Edition|skyrim special edition/skyrimse.exe
::G|363408634568376320|Outlast|olgame.exe
::G|363408709495291934|Depth|depthgame.exe
::G|363408834095742976|Tabletop Simulator|tabletop simulator.exe
::G|363408909962182683|Stellaris|stellaris.exe
::G|363409000399634432|Trove|trove.exe
::G|363409129643180032|Gang Beasts|gang beasts.exe
::G|363409179668512788|The Forest|theforest.exe
::G|363409417632481280|Europa Universalis IV|eu4.exe
::G|363409532480913408|Robocraft|robocraftclient.exe
::G|363409575321403402|Golf It|golfit-win64-shipping.exe
::G|363409615620407316|Shadowverse|shadowverse.exe
::G|363409643973771264|7 Days to Die|7daystodie.exe
::G|363409749175173120|Killing Floor 2|kfgame.exe
::G|363409849859571722|UNDERTALE|undertale.exe
::G|363411278527594516|Business Tour - Online Multiplayer Board Game|businesstour.exe
::G|363411364552638464|Fallout Shelter|falloutshelter.exe
::G|363411395854991400|Slime Rancher|slimerancher.exe
::G|363411468441354240|Titanfall 2|titanfall2.exe
::G|363412167934083072|Star Wars Battlefront|starwarsbattlefront.exe
::G|363412489599188992|Star Wars: The Old Republic|swtor.exe
::G|363412528308682752|PlanetSide 2|planetside2_x64.exe
::G|363412675650125825|Psychonauts|psychonauts.exe
::G|363412728888557568|Call of Duty: World at War|codwaw.exe
::G|363412799117852672|Crossout|crossout.exe
::G|363413176605212682|Comedy Night|comedy night.exe
::G|363413202090065920|Enter the Gungeon|enter the gungeon/etg.exe
::G|363413225578037248|Elite: Dangerous|elitedangerous64.exe
::G|363413310474813450|Wizard101|wizard101.exe
::G|363413365667921930|AdVenture Capitalist|adventure-capitalist.exe
::G|363413389021675530|Age of Empires II: HD Edition|age2_x1.exe
::G|363413402300710912|EVE Online|exefile.exe
::G|363413452976553984|Heat Signature|heat_signature.exe
::G|363413465584500737|RimWorld|rimworld914win.exe
::G|363413743335374859|BeamNG.drive|beamng.drive.x64.exe
::G|363413834301571072|Sid Meier's Civilization VI|civilizationvi.exe
::G|363413894602948608|The Elder Scrolls Online|game/client/eso64.exe
::G|363413961967927306|DOOM|doomx64.exe
::G|363414030188150801|FTL: Faster Than Light|ftlgame.exe
::G|363414140502671360|Just Cause 3|justcause3.exe
::G|363414173457186826|Portal|hl2p.exe
::G|363414443129831444|Dragon Ball: Xenoverse 2|dbxv2.exe
::G|363414482615271434|Friday the 13th: The Game|summercamp.exe
::G|363414635812093962|Prison Architect|prison architect.exe
::G|363414667797725184|Tekken 7|tekkengame-win64-shipping.exe
::G|363414712186306560|The Escapists 2|theescapists2.exe
::G|363414742661988352|Crusader Kings II|ck2game.exe
::G|363424997080956928|Middle-earth: Shadow of Mordor|shadowofmordor.exe
::G|363425113879609344|Metal Gear Solid V: The Phantom Pain|mgsvtpp.exe
::G|363425133274333214|Idle Champions of the Forgotten Realms|idledragons.exe
::G|363425213905371146|Ultimate Chicken Horse|ultimatechickenhorse.exe
::G|363425276300099584|NieR: Automata|nierautomata.exe
::G|363426741269692416|DARK SOULS II: Scholar of the First Sin|darksoulsii.exe
::G|363426802640617482|Total War: Warhammer II|warhammer2.exe
::G|363426862363574272|Skullgirls|skullgirls.exe
::G|363426921612181504|Farming Simulator 17|farmingsimulator2017game.exe
::G|363427044333191169|100 Orange Juice|100orange.exe
::G|363427270024626176|Call of Duty: Black Ops II|t6sp.exe
::G|363427419249442816|Sonic Adventure 2|sonic2app.exe
::G|363427574707257354|Dishonored|dishonored.exe
::G|363427674309263360|Sven Co-op|svencoop.exe
::G|363427800088313856|Tower Unite|tower-win64-shipping.exe
::G|363427839137153024|Dying Light|dyinglightgame.exe
::G|363427969324023808|Chivalry: Medieval Warfare|cmw.exe
::G|363428011980357632|Squad|squad/squadgame/binaries/win64/squadgame.exe
::G|363428060604792832|ASTRONEER|astro-win64-shipping.exe
::G|363428220617621504|Oddworld: Abe's Oddysee|oddworld abes oddysee/abewin.exe
::G|363428336749379604|Tom Clancy's Ghost Recon: Wildlands|grw.exe
::G|363429268577058816|Warhammer: End Times - Vermintide|vermintide.exe
::G|363429406376722442|Kerbal Space Program|ksp_x64.exe
::G|363429423728427008|Rise of the Tomb Raider|rottr.exe
::G|363429491034554368|Infestation: The New Z|thenewz.exe
::G|363429717698936852|Star Wars Battlefront II|starwarsbattlefrontii.exe
::G|363430002181668864|Cuphead|cuphead.exe
::G|363430045970071552|Naruto Shippuden: Ultimate Ninja Storm 4|nsuns4.exe
::G|363430088521547786|TERA|tera.exe
::G|363430103306338304|Saints Row IV|saintsrowiv.exe
::G|363430239134547978|Absolver|absolver-win64-shipping.exe
::G|363430304746176512|Scrap Mechanic|scrapmechanic.exe
::G|363430471322828800|Oxygen Not Included|oxygennotincluded.exe
::G|363430548028522496|Half-Life|hl.exe
::G|363430560942653440|Nuclear Throne|nuclearthrone.exe
::G|363430739456425994|The Sims 3|ts3.exe
::G|363430797257998356|Divinity: Original Sin - Enhanced Edition|divinity original sin/bin/eocapp.exe
::G|363430881811234816|Ravenfield|ravenfield.exe
::G|363430904867192832|Life Is Strange|lifeisstrange.exe
::G|363431029484027904|Hollow Knight|hollow_knight.exe
::G|363431107527704576|Saints Row: The Third|saintsrowthethird_dx11.exe
::G|363431197960962049|Planet Coaster|planetcoaster.exe
::G|363431216000532480|Dishonored 2|dishonored2.exe
::G|363431307629559808|Clustertruck|clustertruck.exe
::G|363431341599096842|Crush Crush|crushcrush.exe
::G|363431403469144064|Battlefield 3|bf3.exe
::G|363431447119527956|WWII Online|wwiionline/ww2.exe
::G|363431541336047616|Company of Heroes 2|reliccoh2.exe
::G|363431556301193216|Realm Grinder|realmgrinderdesktop.exe
::G|363431703504748544|Project CARS|pcars64.exe
::G|363445589247131668|ROBLOX|roblox.exe
::G|363447565905166336|Grand Theft Auto: San Andreas|gta_sa.exe
::G|372438022647578634|Destiny 2|destiny2.exe
::G|372440317493903380|Hob|hob.exe
::G|372825995084038144|Fallout: A Post Nuclear Role Playing Game|falloutw.exe
::G|372826898465685519|Middle-earth: Shadow of War|shadowofwar.exe
::G|376171871873400832|Wolfenstein: The New Order|wolfneworder_x64.exe
::G|376180187806695462|Day of Infamy|dayofinfamy.exe
::G|376180386801123358|Deceit|deceit.exe
::G|376180518749995028|Darkest Dungeon|darkest.exe
::G|376180724291731472|Bendy and the Ink Machine|batim.exe
::G|376181155868966912|Besiege|besiege.exe
::G|376181248596508672|Life is Strange: Before the Storm|life is strange - before the storm.exe
::G|385537854320934922|FIFA 18|fifa18.exe
::G|385537957806866432|Sanctum 2|sanctumgame-win32-shipping.exe
::G|385538103831429120|Human: Fall Flat|human.exe
::G|385538388419280896|Assassin's Creed Origins|acorigins.exe
::G|385538625221165056|CS2D|cs2d.exe
::G|385538682184269834|Wolfenstein II: The New Colossus|newcolossus_x64vk.exe
::G|385538724592746496|DayZ|dayz_x64.exe
::G|385538840162467860|Brtal Legend|brutallegend.exe
::G|387375748262002710|Zombidle: Remonstered|zombidle.exe
::G|387376045269057564|Shadowrun: Hong Kong - Extended Edition|srhk.exe
::G|387402304158040074|Rising Storm 2: Vietnam|vngame.exe
::G|387402920238383122|Elsword|elsword.exe
::G|387403734080159763|Total War: Rome II|rome2.exe
::G|389968138688659466|Getting Over It with Bennett Foddy|getting over it/gettingoverit.exe
::G|398632010442211348|VRChat|vrchat/vrchat.exe
::G|406637677199360030|Assassin's Creed IV Black Flag|ac4bfsp.exe
::G|406637848297472017|Escape from Tarkov|escapefromtarkov.exe
::G|406637935417622558|SCP: Secret Laboratory|scpsl.exe
::G|406638043894775819|They Are Billions|theyarebillions.exe
::G|406638150857785344|The Long Dark|tld.exe
::G|406638362196312074|Kingdom: Classic|kingdom.exe
::G|406643893007024149|Don't Starve|dontstarve.exe
::G|406645058599780368|Kingdoms and Castles|kingdomsandcastles.exe
::G|406645260987662366|Broforce|broforce_beta.exe
::G|406645401437863936|Neverwinter|neverwinter.exe
::G|406645450863804416|Tibia|tibia.exe
::G|406645580375392256|Papers Please|papersplease.exe
::G|406645631864537088|Closers|closers/cw.exe
::G|406645798680657920|Spore|sporeapp.exe
::G|406645878980476928|Plague Inc: Evolved|plagueincevolved.exe
::G|406645950782636041|Borderlands: The Pre-Sequel|borderlandspresequel.exe
::G|406646037571436544|Hotline Miami|hotlinemiami.exe
::G|406646161563189258|theHunter: Call of the Wild|thehuntercotw_f.exe
::G|406646264093212682|Tomb Raider|tombraider.exe
::G|406646387875250186|We Were Here|we were here.exe
::G|406646471098892298|This War of Mine|this war of mine.exe
::G|406646550731816960|Hotline Miami 2: Wrong Number|hotlinemiami2.exe
::G|419267878014025728|Kingdom Come: Deliverance|kingdomcomedeliverance/bin/win64/kingdomcome.exe
::G|419268865667629056|Dragon Ball FighterZ|dbfighterz.exe
::G|419271532087607296|Battalion Legacy|battalion.exe
::G|419272031960432651|World of Tanks: Blitz|wotblitz.exe
::G|421150676710588416|Dark Souls: Prepare to Die Edition|dark souls prepare to die edition/data/darksouls.exe
::G|421150694683312138|Doki Doki Literature Club|ddlc.exe
::G|421150698168909834|Borderlands 2|borderlands2.exe
::G|421858437039783936|SoulWorker|soulworker.exe
::G|424719708785344525|Warcraft III: Reign of Chaos|warcraft iii.exe
::G|425433703041335346|Assassin's Creed Chronicles: China|accgame-win32-shipping.exe
::G|425434983080001556|Assassin's Creed Rogue|acc.exe
::G|425435232788021258|Assassin's Creed Brotherhood|acbmp.exe
