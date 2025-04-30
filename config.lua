--[[                                                --------------------------------->     FOR ASSISTANCE,SCRIPTS AND MORE JOIN OUR DISCORD (https://discord.gg/gbJ5SyBJBv) <---------------------------------                                                                                                                                                                                    
                                                                                                                                                                                                                                 
               AAA               NNNNNNNN        NNNNNNNN                 XXXXXXX       XXXXXXX   SSSSSSSSSSSSSSS TTTTTTTTTTTTTTTTTTTTTTTUUUUUUUU     UUUUUUUUDDDDDDDDDDDDD      IIIIIIIIII     OOOOOOOOO        SSSSSSSSSSSSSSS 
              A:::A              N:::::::N       N::::::N                 X:::::X       X:::::X SS:::::::::::::::ST:::::::::::::::::::::TU::::::U     U::::::UD::::::::::::DDD   I::::::::I   OO:::::::::OO    SS:::::::::::::::S
             A:::::A             N::::::::N      N::::::N                 X:::::X       X:::::XS:::::SSSSSS::::::ST:::::::::::::::::::::TU::::::U     U::::::UD:::::::::::::::DD I::::::::I OO:::::::::::::OO S:::::SSSSSS::::::S
            A:::::::A            N:::::::::N     N::::::N                 X::::::X     X::::::XS:::::S     SSSSSSST:::::TT:::::::TT:::::TUU:::::U     U:::::UUDDD:::::DDDDD:::::DII::::::IIO:::::::OOO:::::::OS:::::S     SSSSSSS
           A:::::::::A           N::::::::::N    N::::::N   ooooooooooo   XXX:::::X   X:::::XXXS:::::S            TTTTTT  T:::::T  TTTTTT U:::::U     U:::::U   D:::::D    D:::::D I::::I  O::::::O   O::::::OS:::::S            
          A:::::A:::::A          N:::::::::::N   N::::::N oo:::::::::::oo    X:::::X X:::::X   S:::::S                    T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::OS:::::S            
         A:::::A A:::::A         N:::::::N::::N  N::::::No:::::::::::::::o    X:::::X:::::X     S::::SSSS                 T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O S::::SSSS         
        A:::::A   A:::::A        N::::::N N::::N N::::::No:::::ooooo:::::o     X:::::::::X       SS::::::SSSSS            T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O  SS::::::SSSSS    
       A:::::A     A:::::A       N::::::N  N::::N:::::::No::::o     o::::o     X:::::::::X         SSS::::::::SS          T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O    SSS::::::::SS  
      A:::::AAAAAAAAA:::::A      N::::::N   N:::::::::::No::::o     o::::o    X:::::X:::::X           SSSSSS::::S         T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O       SSSSSS::::S 
     A:::::::::::::::::::::A     N::::::N    N::::::::::No::::o     o::::o   X:::::X X:::::X               S:::::S        T:::::T         U:::::D     D:::::U   D:::::D     D:::::DI::::I  O:::::O     O:::::O            S:::::S
    A:::::AAAAAAAAAAAAA:::::A    N::::::N     N:::::::::No::::o     o::::oXXX:::::X   X:::::XXX            S:::::S        T:::::T         U::::::U   U::::::U   D:::::D    D:::::D I::::I  O::::::O   O::::::O            S:::::S
   A:::::A             A:::::A   N::::::N      N::::::::No:::::ooooo:::::oX::::::X     X::::::XSSSSSSS     S:::::S      TT:::::::TT       U:::::::UUU:::::::U DDD:::::DDDDD:::::DII::::::IIO:::::::OOO:::::::OSSSSSSS     S:::::S
  A:::::A               A:::::A  N::::::N       N:::::::No:::::::::::::::oX:::::X       X:::::XS::::::SSSSSS:::::S      T:::::::::T        UU:::::::::::::UU  D:::::::::::::::DD I::::::::I OO:::::::::::::OO S::::::SSSSSS:::::S
 A:::::A                 A:::::A N::::::N        N::::::N oo:::::::::::oo X:::::X       X:::::XS:::::::::::::::SS       T:::::::::T          UU:::::::::UU    D::::::::::::DDD   I::::::::I   OO:::::::::OO   S:::::::::::::::SS 
AAAAAAA                   AAAAAAANNNNNNNN         NNNNNNN   ooooooooooo   XXXXXXX       XXXXXXX SSSSSSSSSSSSSSS         TTTTTTTTTTT            UUUUUUUUU      DDDDDDDDDDDDD      IIIIIIIIII     OOOOOOOOO      SSSSSSSSSSSSSSS     

                                                 --------------------------------->     FOR ASSISTANCE,SCRIPTS AND MORE JOIN OUR DISCORD (https://discord.gg/gbJ5SyBJBv) <---------------------------------                                                                                                                                                                                                                                    
--]]
Config = {}
Config.Framework = 'qbox' -- 'esx', 'qbcore', 'qbox',
Config.Locale = 'en' -- 'en'
Config.Notify = 'ox' -- 'ox', 'qb', 'esx'
Config.Target = 'ox' -- 'ox', 'qb'
Config.Menu = 'ox' -- 'ox', 'qb', 'esx'
Config.ProgressBar = 'ox' -- 'ox', 'qb', 'esx'
Config.PedModel = 'g_m_m_armboss_01'
Config.PedScenario = 'WORLD_HUMAN_SMOKING'

Config.UseDirtyMoney = true -- true = uses black_money/markedbills, false = uses regular money
Config.EnableBlip = true -- Set to false to disable the black market blip
Config.Debug = false
Config.LocationChangeTime = 10 -- Location change timer (in minutes)

Config.TargetOptions = {
    icon = "fas fa-shopping-cart",
    distance = 2.0
}

Config.Locations = {
    {
        coords = vector4(-1172.8505, -1569.1763, 4.3917, 300.2798),
        blip = {
            sprite = 524,
            color = 1,
            scale = 0.7,
            label = "Black Market"
        }
    },
    {
        coords = vector4(1240.1276, -3168.0750, 7.1049, 274.8748),
        blip = {
            sprite = 524,
            color = 1,
            scale = 0.7,
            label = "Black Market"
        }
    },
    {
        coords = vector4(726.5413, 4169.9854, 40.7092, 354.4087),
        blip = {
            sprite = 524,
            color = 1,
            scale = 0.7,
            label = "Black Market"
        }
    }
}

Config.Items = {
    {
        label = "Pistol",
        item = "WEAPON_PISTOL",
        price = 500,
        description = "Kill People With This",
        metadata = {}
    },
    {
        label = "Knife",
        item = "WEAPON_KNIFE",
        price = 2000,
        description = "Stab People With This",
        metadata = {}
    },
    {
        label = "Bandage",
        item = "bandage",
        price = 5000,
        description = "Heal Wounds",
        metadata = {}
    },
    {
        label = "Copper",
        item = "copper",
        price = 3500,
        description = "Maybe Use to Craft?",
        metadata = {}
    },
    {
        label = "Iron",
        item = "iron",
        price = 750,
        description = "Maybe Use to Craft?",
        metadata = {}
    }
}
