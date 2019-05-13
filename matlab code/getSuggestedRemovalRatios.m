%% getSuggestedRemovalRatios

function [removalRatioStart, removalRatioEnd] = getSuggestedRemovalRatios(taskSelection)

suggestedRemovalRatioStart.universalStairs = 0.7;
suggestedRemovalRatioEnd.universalStairs = 0.1;

suggestedRemovalRatioStart.universalTrot = 0.25;
suggestedRemovalRatioEnd.universalTrot = 0.05;

suggestedRemovalRatioStart.speedyGallop = 0.3;
suggestedRemovalRatioEnd.speedyGallop = 0.1;

suggestedRemovalRatioStart.speedyStairs = 0.5;
suggestedRemovalRatioEnd.speedyStairs = 0.2;

suggestedRemovalRatioStart.massivoWalk = 0.2;
suggestedRemovalRatioEnd.massivoWalk = 0.1;

suggestedRemovalRatioStart.massivoStairs = 0.3;
suggestedRemovalRatioEnd.massivoStairs = 0.6;

suggestedRemovalRatioStart.centaurStairs = 0.3;
suggestedRemovalRatioEnd.centaurStairs = 0.6;

suggestedRemovalRatioStart.centaurWalk = 0.2;
suggestedRemovalRatioEnd.centaurWalk = 0.1;

suggestedRemovalRatioStart.miniPronk = 0.1;
suggestedRemovalRatioEnd.miniPronk = 0.1;



removalRatioStart = suggestedRemovalRatioStart.(taskSelection);
removalRatioEnd = suggestedRemovalRatioEnd.(taskSelection);