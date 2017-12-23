local tiles = {
    {
        name = "sky",
        invisible = true
    },

    {
        name = "ground",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE,
        breakable = true
    },
    
    {
        name = "coinBlock",
        collision = COLLISION.CUBE,
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
        collision = COLLISION.CUBE,
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
        collision = COLLISION.CUBE
    },
    
    {
        name = "whitepipetopright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "greenpipetopleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "greenpipetopright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipetopleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipetopright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "mushroomleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "mushroomcenter",
        collision = COLLISION.CUBE
    },
    
    {
        name = "mushroomright",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },
    
    {
        name = "whitepipebottomright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "greenpipebottomleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "greenpipebottomright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipebottomleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipebottomright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "cannontop",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE,
        breakable = true
    },
    
    {
        name = "groundunderground",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },
    
    {
        name = "greenpipelefttopright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "greenpipemiddletop",
        collision = COLLISION.CUBE
    },
    
    {
        name = "underwaterpipetop",
        collision = COLLISION.CUBE
    },
    
    {
        name = "whitepipetopleft",
        collision = COLLISION.CUBE
    },

    {
        name = "whitepipetopright",
        collision = COLLISION.CUBE
    },

    {
        name = "cannonbottom",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },
    
    {
        name = "treeplatformmiddle",
        collision = COLLISION.CUBE
    },
    
    {
        name = "treeplatformright",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },

    {
        name = "whitetreetop"
    },

    {
        name = "blockalt",
        collision = COLLISION.CUBE
    },

    {
        name = "cloudplatform",
        collision = COLLISION.CUBE
    },

    {
        name = "greenpipeleftbottomleft",
        collision = COLLISION.CUBE
    },

    {
        name = "greenpipeleftbottomright",
        collision = COLLISION.CUBE
    },

    {
        name = "greenpipemiddlebottom",
        collision = COLLISION.CUBE
    },

    {
        name = "underwaterpipebottom",
        collision = COLLISION.CUBE
    },

    {
        name = "whitepipebottomleft",
        collision = COLLISION.CUBE
    },

    {
        name = "whitepipebottomright",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },
    
    {
        name = "whitetreeplatformmiddle",
        collision = COLLISION.CUBE
    },
    
    {
        name = "whitetreeplatformright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "whiteground",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },
    














    {
        name = "undergroundblockalt",
        collision = COLLISION.CUBE
    },
    
    {
        name = "unused"
    },
    
    {
        name = "coinblockempty",
        collision = COLLISION.CUBE
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
        collision = COLLISION.CUBE
    },
    
    {
        name = "lavamiddle"
    },
    
    {
        name = "skyvisible"
    },
    
    {
        name = "whiteblock",
        collision = COLLISION.CUBE
    },
    
    {
        name = "morewatermiddle"
    },
    
    {
        name = "redpipebottomleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipebottomright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipetopleft",
        collision = COLLISION.CUBE
    },
    
    {
        name = "redpipetopright",
        collision = COLLISION.CUBE
    },
    
    {
        name = "underwaterblock",
        collision = COLLISION.CUBE
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
