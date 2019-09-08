--------------------
-- EzDismount Tables
--------------------

BINDING_HEADER_EZDISMOUNT  = "EzDismount";
BINDING_NAME_EZDISMOUNT    = "Dismount";

EzDSitErr = SPELL_FAILED_NOT_STANDING;

EzDExcludeMoon = "spell_nature_forceofnature";
EzDExcludeTree = "ability_druid_treeoflife";

EzDHelp = {
         ["List"] = {"Type /ezd              Config Menu",
                     "Type /ezd reset     Reset Configuration",
                     "Type /ezd reload   Reload UI",
                     "Type /ezd debug   Print debug info",
                    },
 };

EzDMountText = { 
        ["Mount"]      = {"_mount_",
                          "_qirajicrystal_"
                         },
        ["Druid"]      = {"ability_racial_bearform",
                          "ability_druid_catform",
                          "ability_druid_travelform",
                          "ability_druid_aquaticform",
                          "spell_nature_forceofnature",
                          "ability_druid_treeoflife"
                         },
        ["Shaman"]     = {"spell_nature_spiritwolf"
                         },
        ["Priest"]     = {"spell_shadow_shadowform"
                         },
 };

EzDMountBuff = {
        ["Exclude"]    = {"aspect of the cheetah",
                          "aspect of the pack"
                         },
	["Mount"]      = {"summon warhorse",
                          "summon felsteed",
	                  "riding talbuk",
	                  "reindeer"
                         },
 };

 -- list from globalstrings.lua
 EzDShiftErr = {
         ["Error"] = {SPELL_FAILED_NOT_SHAPESHIFT,
                      SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED,
                      SPELL_NOT_SHAPESHIFTED,
                      SPELL_NOT_SHAPESHIFTED_NOSPACE,
                      ERR_CANT_INTERACT_SHAPESHIFTED,
                      ERR_NOT_WHILE_SHAPESHIFTED,
                      ERR_NO_ITEMS_WHILE_SHAPESHIFTED,
                      ERR_TAXIPLAYERSHAPESHIFTED,
                      ERR_MOUNT_SHAPESHIFTED,
                      ERR_EMBLEMERROR_NOTABARDGEOSET,
                     },
 };

 -- list from globalstrings.lua
 EzDMountErr = {
         ["Error"] = {SPELL_FAILED_NOT_MOUNTED,
                      ERR_ATTACK_MOUNTED,
                     },
 };
