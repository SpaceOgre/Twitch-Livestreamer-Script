# This script will check all twitch channels added to the $channels array and list those that are live.
# You can then choose which you want to watch and livestreamer does the rest.
# Require: 
#   PowerShell 4 (https://www.microsoft.com/en-us/download/details.aspx?id=40855)
#   livestreamer (http://docs.livestreamer.io/)
# Optional: 
#   HexChat (https://hexchat.github.io/)

# DO NOT CHANGE THIS
#------------------------------------------------------------------------------
$liveChannels = {@()}.Invoke();
$url = "http://www.twitch.tv/";
$apiUrl = "https://api.twitch.tv/kraken/streams/";
#------------------------------------------------------------------------------

# Mandatory Settings - Required but they can be changed to your preference
#------------------------------------------------------------------------------
# Set quality to use: see livestreamer documentation
$quality = "best";
# Add channels you want checked here
$channels = @("AdmiralBulldog", "RaizQT", "ProjectPT", "BeyondTheSummit", "Bacon_Donut", "DansGaming", "ZiggyDLive", "sc2proleague");
#------------------------------------------------------------------------------

# Optional Settings - Comment out the options you don't want
#------------------------------------------------------------------------------
# Add path to HexChat if you want to connect to the selected channels chat.
# HexChat needs to be configured for irc.twitch.tv. Server name: Twitch
$hexChatPath = "C:\Program Files\HexChat\hexchat.exe";
#------------------------------------------------------------------------------

cls;

echo "Channels that are live"
echo "----------------------"
$streams = (Invoke-RestMethod $($apiUrl + "?channel=" +  $($channels -join ','))).streams;
$i = 0;
foreach ($stream in $streams){
		echo $("[" + $i + "] - " + $stream.channel.display_name + " - " + $stream.game);
		write-host $("`t`t" + $stream.channel.status) -foregroundcolor "yellow";
		$liveChannels.add($stream.channel.display_name) | Out-Null;
		$i++;
}

if($liveChannels.Count -eq 0){
	echo "No channels are live, exiting...";
	echo "";
	Exit;
}

echo "----------------------";
echo "";

DO {
	[int] $choice = Read-Host -Prompt "Choose one of the above numbers"

	if($choice -le $($liveChannels.Count - 1)){
		if($hexChatPath -ne $null){
			& $hexChatPath $("irc://Twitch/#" + $liveChannels[$choice].ToLower())
		}
		& "livestreamer" $($url + $liveChannels[$choice]) $quality
		break;
	}
	else {
		echo "Not a valid choice";
		echo "";
	}
} While ($true)