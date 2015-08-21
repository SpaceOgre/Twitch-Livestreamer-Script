#------------------------------------------------------------------------------
# This script will check all twitch channels added to the channels.txt file
# and list those that are live. You can then choose which you want to watch 
# and livestreamer does the rest.
# 
# Require: 
#   PowerShell 4 (https://www.microsoft.com/en-us/download/details.aspx?id=40855)
#   livestreamer (http://docs.livestreamer.io/)
# Optional: 
#   HexChat (https://hexchat.github.io/)
#------------------------------------------------------------------------------
# DO NOT CHANGE THIS
#------------------------------------------------------------------------------
$url = "http://www.twitch.tv/";
$apiUrl = "https://api.twitch.tv/kraken";
$streamsUrl = $apiUrl + "/streams";
$followingUrl = $apiUrl + "/users/{0:S}/follows/channels?limit=100";
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Mandatory Settings - Required but they can be changed to your preference
#------------------------------------------------------------------------------
# Set quality to use: see livestreamer documentation
$quality = "best";

# To check channels that you have followed set username
$twitchUsername = "spaceogre";
# Otherwise you can add channels you want checked to a file called 
# "channels.txt" and put it in the same folder as this script.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Optional Settings - Comment out the options you don't want
#------------------------------------------------------------------------------
# Add path to HexChat if you want to connect to the selected channels chat.
# HexChat needs to be configured for irc.twitch.tv. Server name: Twitch
$hexChatPath = "C:\Program Files\HexChat\hexchat.exe";
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------
function main{
    cls;

    $channels = getChannels;

    write-host "Channels that are live"
    printHR;

    $liveChannels = getLiveChannels $channels;

    printHR;
    write-host "";

    chooseChannel $liveChannels;

    printHR;
    write-host "";

    $choice = Read-Host -Prompt "Run script again? [Y/N]";

    if($choice -like "yes" -Or ($choice -like "y")){
        main;
    }
}

function getChannels{
    if($twitchUsername -eq $null -Or $twitchUsername -eq ""){
        return getChannelsFromFile;
    } 
    else{
        return getChannelsFromUsername;
    }
}

function getChannelsFromFile{
    if(!(Test-Path "channels.txt")){
        write-host "channels.txt is missing!";
        write-host "Add it to the same folder as the script, ";
        write-host "with one channel per line.";
        Exit;
    }
    return Get-Content "channels.txt";
}

function getChannelsFromUsername{
    $channels = {@()}.Invoke();
    $follows = (Invoke-RestMethod $($followingUrl -f $twitchUsername)).follows;
    foreach($channel in $follows){
        $channels.Add($channel.channel.name) | Out-Null;
    }
    return $channels;
}

function getLiveChannels($channels){
    $streams = (Invoke-RestMethod $($streamsUrl + "?channel=" +  $($channels -join ','))).streams;
    $liveChannels = {@()}.Invoke();
    $i = 0;
    foreach ($stream in $streams){
            write-host $("[" + $i + "] - " + $stream.channel.display_name + " - " + $stream.game);
            write-host $("`t`t" + $stream.channel.status) -foregroundcolor "yellow";
            $liveChannels.add($stream.channel.display_name) | Out-Null;
            $i++;
    }

    if($liveChannels.Count -eq 0){
        write-host "No channels are live, exiting...";
        write-host "";
        Exit;
    }
	
	return $liveChannels;
}

function chooseChannel($liveChannels){
    DO {
        $choice = Read-Host -Prompt "Choose one of the above numbers or type [e]xit";
        write-host "";
    
        if($choice -eq "exit" -Or ($choice -eq "e")){
            Exit;
        }
    
        if($choice -le $($liveChannels.Count - 1)){
            if($hexChatPath -ne $null -And (Test-Path $hexChatPath)){
                & $hexChatPath $("irc://Twitch/#" + $liveChannels[$choice].ToLower())
            }
            write-host "Livestreamer output: ";
            printHR;
            & "livestreamer" $($url + $liveChannels[$choice]) $quality
            break;
        }
        else {
            write-host "Not a valid choice";
            write-host "";
        }
    } While ($true)
}

function printHR{
    write-host "------------------------------------------------------------------";
}

#------------------------------------------------------------------------------
# Run the script
#------------------------------------------------------------------------------
main