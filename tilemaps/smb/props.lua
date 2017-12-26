local tiles = {
    {
        name = "sky",
        invisible = true
    },

    {
        name = "ground",
        collision = VAR("collision").cube
    },
    
    {
        name = "hilltop",
    },
    
    {
        name = "bushleft",
    },
    
    {
        name = "bushcenter",
    },
    
    {
        name = "bushright",
    },
    
    {
        name = "block",
        collision = VAR("collision").cube,
        breakable = true
    },
    
    {
        name = "coinBlock",
        collision = VAR("collision").cube,
        coinBlock = true,
        type = "coinAnimation",
        img = "img/coinBlock.png"
    },
    
    {
        name = "unused",
        invisible = true
    },
    
    {
        name = "chain",
        bowserbridge = true
    },
    
    {
        name = "bowserbridge",
        collision = VAR("collision").cube,
        bowserbridge = true
    },
    
    {
        name = "fence"
    },
    
    {
        name = "fencewhite"
    },
    
    {
        name = "whitepipetopleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "whitepipetopright",
        collision = VAR("collision").cube
    },
    
    {
        name = "greenpipetopleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "greenpipetopright",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipetopleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipetopright",
        collision = VAR("collision").cube
    },
    
    {
        name = "mushroomleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "mushroomcenter",
        collision = VAR("collision").cube
    },
    
    {
        name = "mushroomright",
        collision = VAR("collision").cube
    },
    
    
    
    
    
    
    
    
    
    
    
    {
        name = "castlemiddle",
    },
    
    {
        name = "hillleft",
    },
    
    {
        name = "hillcenter",
    },
    
    {
        name = "hillright",
    },
    
    {
        name = "hillcenteralt1",
    },
    
    {
        name = "hillcenteralt2",
    },
    
    {
        name = "castleground",
        collision = VAR("collision").cube
    },
    
    {
        name = "redcloudtopleft",
    },
    
    {
        name = "redcloudtop",
    },
    
    {
        name = "redcloudtopright",
    },
    
    {
        name = "bluecloudtopleft",
    },
    
    {
        name = "bluecloudtop",
    },
    
    {
        name = "bluecloudtopright",
    },
    
    {
        name = "whitepipebottomleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "whitepipebottomright",
        collision = VAR("collision").cube
    },
    
    {
        name = "greenpipebottomleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "greenpipebottomright",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipebottomleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipebottomright",
        collision = VAR("collision").cube
    },
    
    {
        name = "cannontop",
        collision = VAR("collision").cube
    },
    
    {
        name = "mushroomcenter"
    },
    
    {
        name = "treetop"
    },








    {
        name = "castletopalt",
    },
    
    {
        name = "castledoortop",
    },
    
    {
        name = "castlemiddle",
    },
    
    {
        name = "redflagtop"
    },
    
    {
        name = "blockunderground",
        collision = VAR("collision").cube,
        breakable = true
    },
    
    {
        name = "groundunderground",
        collision = VAR("collision").cube
    },
    
    {
        name = "whitecastletopalt",
    },
    
    {
        name = "redcloudbottomleft",
    },
    
    {
        name = "redcloudbottom",
    },
    
    {
        name = "redcloudbottomright",
    },
    
    {
        name = "bluecloudbottomleft",
    },
    
    {
        name = "bluecloudbottom",
    },
    
    {
        name = "bluecloudbottomright",
    },
    
    {
        name = "greenpipelefttopleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "greenpipelefttopright",
        collision = VAR("collision").cube
    },
    
    {
        name = "greenpipemiddletop",
        collision = VAR("collision").cube
    },
    
    {
        name = "underwaterpipetop",
        collision = VAR("collision").cube
    },
    
    {
        name = "whitepipetopleft",
        collision = VAR("collision").cube
    },

    {
        name = "whitepipetopright",
        collision = VAR("collision").cube
    },

    {
        name = "cannonbottom",
        collision = VAR("collision").cube
    },
    
    {
        name = "mushroombottom"
    },
    
    {
        name = "treebottom"
    },












    
    {
        name = "castleleft",
    },

    {
        name = "castledoorbottom",
    },

    {
        name = "castleright",
    },

    {
        name = "treeplatformleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "treeplatformmiddle",
        collision = VAR("collision").cube
    },
    
    {
        name = "treeplatformright",
        collision = VAR("collision").cube
    },

    {
        name = "whitecastletop",
    },

    {
        name = "whitecastledoortop",
    },

    {
        name = "whitecastlemiddle",
    },

    {
        name = "underwaterplant",
        collision = VAR("collision").cube
    },

    {
        name = "whitetreetop"
    },

    {
        name = "blockalt",
        collision = VAR("collision").cube
    },

    {
        name = "cloudplatform",
        collision = VAR("collision").cube
    },

    {
        name = "greenpipeleftbottomleft",
        collision = VAR("collision").cube
    },

    {
        name = "greenpipeleftbottomright",
        collision = VAR("collision").cube
    },

    {
        name = "greenpipemiddlebottom",
        collision = VAR("collision").cube
    },

    {
        name = "underwaterpipebottom",
        collision = VAR("collision").cube
    },

    {
        name = "whitepipebottomleft",
        collision = VAR("collision").cube
    },

    {
        name = "whitepipebottomright",
        collision = VAR("collision").cube
    },

    {
        name = "fence"
    },

    {
        name = "smalltreetop"
    },

    {
        name = "treetrunk"
    },













    
    {
        name = "whitetreeplatformleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "whitetreeplatformmiddle",
        collision = VAR("collision").cube
    },
    
    {
        name = "whitetreeplatformright",
        collision = VAR("collision").cube
    },
    
    {
        name = "whiteground",
        collision = VAR("collision").cube
    },
    
    {
        name = "treeplatformtrunk"
    },
    
    {
        name = "whitetreeplatformtrunk"
    },
    
    {
        name = "whitecastleleft"
    },
    
    {
        name = "whitecastlemiddle"
    },
    
    {
        name = "whitecastleright"
    },
    
    {
        name = "underwaterground"
    },
    
    {
        name = "whitetreebottom"
    },
    
    {
        name = "greenflagtop"
    },
    
    {
        name = "whiteflagtop"
    },
    
    {
        name = "anotherflagtop"
    },
    
    {
        name = "greenflagpole"
    },
    
    {
        name = "whiteflagpole"
    },
    
    {
        name = "anotherflagpole"
    },
    
    {
        name = "water"
    },
    
    {
        name = "lava"
    },
    
    {
        name = "differentwater?"
    },
    
    {
        name = "whitesmalltree"
    },
    
    {
        name = "bridge",
        collision = VAR("collision").cube
    },
    














    {
        name = "undergroundblockalt",
        collision = VAR("collision").cube
    },
    
    {
        name = "unused"
    },
    
    {
        name = "coinblockempty",
        collision = VAR("collision").cube
    },
    
    {
        name = "unused"
    },
    
    {
        name = "unused"
    },
    
    {
        name = "unused"
    },
    
    {
        name = "unused"
    },
    
    {
        name = "unused"
    },
    
    {
        name = "cannonlong",
        collision = VAR("collision").cube
    },
    
    {
        name = "lavamiddle"
    },
    
    {
        name = "skyvisible"
    },
    
    {
        name = "whiteblock",
        collision = VAR("collision").cube
    },
    
    {
        name = "morewatermiddle"
    },
    
    {
        name = "redpipebottomleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipebottomright",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipetopleft",
        collision = VAR("collision").cube
    },
    
    {
        name = "redpipetopright",
        collision = VAR("collision").cube
    },
    
    {
        name = "underwaterblock",
        collision = VAR("collision").cube
    },
    
    {
        name = "anothergoddamnflagpole"
    },
    
    {
        name = "unused"
    },
    
    {
        name = "unused"
    },
    
    {
        name = "unused"
    }
}

local props = {
    tileSize = 16,
    tileMap = "tiles.png",
    tiles = tiles
}

return props
