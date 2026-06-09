local CampaignData = require("reboot.data.CampaignData")

local StarterLevels = {}

local firstChapter = CampaignData.chapters and CampaignData.chapters[1] or {}

StarterLevels.chapter = {
    id = firstChapter.id,
    name = firstChapter.name,
    districtName = firstChapter.districtName,
    tagline = firstChapter.tagline,
    mechanicFocus = firstChapter.mechanicFocus,
    mechanicSummary = firstChapter.mechanicSummary,
}

StarterLevels.levels = firstChapter.levels or {}

return StarterLevels
