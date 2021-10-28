#===================================================================================================

Set-StrictMode -Version Latest

#===================================================================================================

function Get-KnownFolderPath
{
    param
    (
        [Parameter(Mandatory = $true)] [string] $FolderName,
        [switch] $NoVerify
    )

    # enhance x64 folders in 32-bit process

    if ($FolderName -eq "SystemX64")
    {
        if ((Test-64BitSystem) -and (-not (Test-64BitProcess)))
        {
            return Join-Path (Get-KnownFolderPath "Windows") "SysNative"
        }

        else
        {
            $FolderName = "System"
        }
    }

    elseif (-not (Test-64BitProcess))
    {
        if ($FolderName -eq "ProgramFilesX64")
        {
            if (Test-64BitSystem)
            {
                return $Env:ProgramW6432
            }

            else
            {
                $FolderName = "ProgramFiles"
            }
        }

        elseif ($FolderName -eq "ProgramFilesCommonX64")
        {
            if (Test-64BitSystem)
            {
                return $Env:CommonProgramW6432
            }

            else
            {
                $FolderName = "ProgramFilesCommon"
            }
        }
    }

    # lookup folder in hash table

    $FolderId = $FolderIds[$FolderName]

    if ($FolderId -eq $null)
    {
        throw "Get-KnownFolderPath: Invalid folder '$FolderName'"
    }

    # get known folder path

    $Flags = $NoVerify ? [KF_FLAG]::DONT_VERIFY : [KF_FLAG]::DEFAULT

    $PathPtr = [System.IntPtr]::Zero

    [Win32.Shell32]::SHGetKnownFolderPath($FolderId, $Flags, [System.IntPtr]::Zero, [ref] $PathPtr)

    # get string from string pointer

    [System.Runtime.InteropServices.Marshal]::PtrToStringUni($PathPtr)

    # free string pointer

    [System.Runtime.InteropServices.Marshal]::FreeCoTaskMem($PathPtr)
}

#===================================================================================================

enum KF_FLAG
{
    DEFAULT = 0x00000000
    CREATE = 0x00008000
    DONT_VERIFY = 0x00004000
    INIT = 0x00000800
    DEFAULT_PATH = 0x00000400
}

#===================================================================================================

$FolderIds =
@{
#   "Network" = [System.Guid] "D20BEEC4-5CA8-4905-AE3B-BF251EA09B53"
#   "Computer" = [System.Guid] "0AC0837C-BBF8-452A-850D-79D08E667CA7"
#   "Internet" = [System.Guid] "4D9F7874-4E0C-4904-967B-40B0D20C3E4B"
#   "ControlPanel" = [System.Guid] "82A74AEB-AEB4-465C-A014-D097EE346D63"
#   "Printers" = [System.Guid] "76FC4E2D-D6AD-4519-A663-37BD56068185"
#   "SyncCenter" = [System.Guid] "43668BF8-C14E-49B2-97C9-747784D784B7"
#   "SyncSetup" = [System.Guid] "0F214138-B1D3-4a90-BBA9-27CBC0C5389A"
#   "Conflict" = [System.Guid] "4bfefb45-347d-4006-a5be-ac0cb0567192"
#   "SyncResults" = [System.Guid] "289a9a43-be44-4057-a41b-587a76d7e7f9"
#   "RecycleBin" = [System.Guid] "B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC"
#   "Connections" = [System.Guid] "6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD"
    "Fonts" = [System.Guid] "FD228CB7-AE11-4AE3-864C-16F3910AB8FE"
    "Desktop" = [System.Guid] "B4BFCC3A-DB2C-424C-B029-7FE99A87C641"
    "Startup" = [System.Guid] "B97D20BB-F46A-4C97-BA10-5E3608430854"
    "Programs" = [System.Guid] "A77F5D77-2E2B-44C3-A6A2-ABA601054A51"
    "StartMenu" = [System.Guid] "625B53C3-AB48-4EC1-BA1F-A1EF4146FC19"
    "Recent" = [System.Guid] "AE50C081-EBD2-438A-8655-8A092E34987A"
    "SendTo" = [System.Guid] "8983036C-27C0-404B-8F08-102D10DCFD74"
    "Documents" = [System.Guid] "FDD39AD0-238F-46AF-ADB4-6C85480369C7"
    "Favorites" = [System.Guid] "1777F761-68AD-4D8A-87BD-30B759FA33DD"
    "NetHood" = [System.Guid] "C5ABBF53-E17F-4121-8900-86626FC2C973"
    "PrintHood" = [System.Guid] "9274BD8D-CFD1-41C3-B35E-B13F55A758F4"
    "Templates" = [System.Guid] "A63293E8-664E-48DB-A079-DF759E0509F7"
    "CommonStartup" = [System.Guid] "82A5EA35-D9CD-47C5-9629-E15D2F714E6E"
    "CommonPrograms" = [System.Guid] "0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8"
    "CommonStartMenu" = [System.Guid] "A4115719-D62E-491D-AA7C-E74B8BE3B067"
    "PublicDesktop" = [System.Guid] "C4AA340D-F20F-4863-AFEF-F87EF2E6BA25"
    "ProgramData" = [System.Guid] "62AB5D82-FDC1-4DC3-A9DD-070D1D495D97"
    "CommonTemplates" = [System.Guid] "B94237E7-57AC-4347-9151-B08C6C32D1F7"
    "PublicDocuments" = [System.Guid] "ED4824AF-DCE4-45A8-81E2-FC7965083634"
    "RoamingAppData" = [System.Guid] "3EB685DB-65F9-4CF6-A03A-E3EF65729F3D"
    "LocalAppData" = [System.Guid] "F1B32785-6FBA-4FCF-9D55-7B8E7F157091"
    "LocalAppDataLow" = [System.Guid] "A520A1A4-1780-4FF6-BD18-167343C5AF16"
    "InternetCache" = [System.Guid] "352481E8-33BE-4251-BA85-6007CAEDCF9D"
    "Cookies" = [System.Guid] "2B0F765D-C0E9-4171-908E-08A611B84FF6"
    "History" = [System.Guid] "D9DC8A3B-B784-432E-A781-5A1130A75963"
    "System" = [System.Guid] "1AC14E77-02E7-4E5D-B744-2EB1AE5198B7"
    "SystemX86" = [System.Guid] "D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27"
    "Windows" = [System.Guid] "F38BF404-1D43-42F2-9305-67DE0B28FC23"
    "Profile" = [System.Guid] "5E6C858F-0E22-4760-9AFE-EA3317B67173"
    "Pictures" = [System.Guid] "33E28130-4E1E-4676-835A-98395C3BC3BB"
    "ProgramFilesX86" = [System.Guid] "7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E"
    "ProgramFilesCommonX86" = [System.Guid] "DE974D24-D9C6-4D3E-BF91-F4455120B917"
    "ProgramFilesX64" = [System.Guid] "6D809377-6AF0-444b-8957-A3773F02200E"
    "ProgramFilesCommonX64" = [System.Guid] "6365D5A7-0F0D-45e5-87F6-0DA56B6A4F7D"
    "ProgramFiles" = [System.Guid] "905e63b6-c1bf-494e-b29c-65b732d3d21a"
    "ProgramFilesCommon" = [System.Guid] "F7F1ED05-9F6D-47A2-AAAE-29D317C6F066"
    "UserProgramFiles" = [System.Guid] "5cd7aee2-2219-4a67-b85d-6c9ce15660cb"
    "UserProgramFilesCommon" = [System.Guid] "bcbd3057-ca5c-4622-b42d-bc56db0ae516"
    "AdminTools" = [System.Guid] "724EF170-A42D-4FEF-9F26-B60E846FBA4F"
    "CommonAdminTools" = [System.Guid] "D0384E7D-BAC3-4797-8F14-CBA229B392B5"
    "Music" = [System.Guid] "4BD8D571-6D19-48D3-BE97-422220080E43"
    "Videos" = [System.Guid] "18989B1D-99B5-455B-841C-AB7C74E4DDFC"
    "Ringtones" = [System.Guid] "C870044B-F49E-4126-A9C3-B52A1FF411E8"
    "PublicPictures" = [System.Guid] "B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5"
    "PublicMusic" = [System.Guid] "3214FAB5-9757-4298-BB61-92A9DEAA44FF"
    "PublicVideos" = [System.Guid] "2400183A-6185-49FB-A2D8-4A392A602BA3"
    "PublicRingtones" = [System.Guid] "E555AB60-153B-4D17-9F04-A5FE99FC15EC"
    "Resources" = [System.Guid] "8AD10C31-2ADB-4296-A8F7-E4701232C972"
    "LocalizedResources" = [System.Guid] "2A00375E-224C-49DE-B8D1-440DF7EF3DDC"
    "OEMLinks" = [System.Guid] "C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D"
    "CDBurning" = [System.Guid] "9E52AB10-F80D-49DF-ACB8-4330F5687855"
    "UserProfiles" = [System.Guid] "0762D272-C50A-4BB0-A382-697DCD729B80"
    "Playlists" = [System.Guid] "DE92C1C7-837F-4F69-A3BB-86E631204A23"
    "SamplePlaylists" = [System.Guid] "15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5"
    "SampleMusic" = [System.Guid] "B250C668-F57D-4EE1-A63C-290EE7D1AA1F"
    "SamplePictures" = [System.Guid] "C4900540-2379-4C75-844B-64E6FAF8716B"
    "SampleVideos" = [System.Guid] "859EAD94-2E85-48AD-A71A-0969CB56A6CD"
    "PhotoAlbums" = [System.Guid] "69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C"
    "Public" = [System.Guid] "DFDF76A2-C82A-4D63-906A-5644AC457385"
#   "ChangeRemovePrograms" = [System.Guid] "df7266ac-9274-4867-8d55-3bd661de872d"
#   "AppUpdates" = [System.Guid] "a305ce99-f527-492b-8b1a-7e76fa98d6e4"
#   "AddNewPrograms" = [System.Guid] "de61d971-5ebc-4f02-a3a9-6c82895e5c04"
    "Downloads" = [System.Guid] "374DE290-123F-4565-9164-39C4925E467B"
    "PublicDownloads" = [System.Guid] "3D644C9B-1FB8-4f30-9B45-F670235F79C0"
    "Searches" = [System.Guid] "7d1d3a04-debb-4115-95cf-2f29da2920da"
    "QuickLaunch" = [System.Guid] "52a4f021-7b75-48a9-9f6b-4b87a210bc8f"
    "Contacts" = [System.Guid] "56784854-C6CB-462b-8169-88E350ACB882"
    "SidebarParts" = [System.Guid] "A75D362E-50FC-4fb7-AC2C-A8BEAA314493"
    "SidebarDefaultParts" = [System.Guid] "7B396E54-9EC5-4300-BE0A-2482EBAE1A26"
    "PublicGameTasks" = [System.Guid] "DEBF2536-E1A8-4c59-B6A2-414586476AEA"
    "GameTasks" = [System.Guid] "054FAE61-4DD8-4787-80B6-090220C4B700"
    "SavedGames" = [System.Guid] "4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4"
#   "Games" = [System.Guid] "CAC52C1A-B53D-4edc-92D7-6B2E8AC19434"
#   "SearchMAPI" = [System.Guid] "98ec0e18-2098-4d44-8644-66979315a281"
#   "SearchCSC" = [System.Guid] "ee32e446-31ca-4aba-814f-a5ebd2fd6d5e"
    "Links" = [System.Guid] "bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968"
#   "UsersFiles" = [System.Guid] "f3ce0f7c-4901-4acc-8648-d5d44b04ef8f"
#   "UsersLibraries" = [System.Guid] "A302545D-DEFF-464b-ABE8-61C8648D939B"
#   "SearchHome" = [System.Guid] "190337d1-b8ca-4121-a639-6d472d16972a"
    "OriginalImages" = [System.Guid] "2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39"
    "DocumentsLibrary" = [System.Guid] "7b0db17d-9cd2-4a93-9733-46cc89022e7c"
    "MusicLibrary" = [System.Guid] "2112AB0A-C86A-4ffe-A368-0DE96E47012E"
    "PicturesLibrary" = [System.Guid] "A990AE9F-A03B-4e80-94BC-9912D7504104"
    "VideosLibrary" = [System.Guid] "491E922F-5643-4af4-A7EB-4E7A138D8174"
    "RecordedTVLibrary" = [System.Guid] "1A6FDBA2-F42D-4358-A798-B74D745926C5"
#   "HomeGroup" = [System.Guid] "52528A6B-B9E3-4add-B60D-588C2DBA842D"
#   "HomeGroupCurrentUser" = [System.Guid] "9B74B6A3-0DFD-4f11-9E78-5F7800F2E772"
    "DeviceMetadataStore" = [System.Guid] "5CE4A5E9-E4EB-479D-B89F-130C02886155"
    "Libraries" = [System.Guid] "1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE"
    "PublicLibraries" = [System.Guid] "48daf80b-e6cf-4f4e-b800-0e69d84ee384"
    "UserPinned" = [System.Guid] "9e3995ab-1f9c-4f13-b827-48b24b6c7174"
    "ImplicitAppShortcuts" = [System.Guid] "bcb5256f-79f6-4cee-b725-dc34e402fd46"
    "AccountPictures" = [System.Guid] "008ca0b1-55b4-4c56-b8a8-4de4b299d3be"
    "PublicAccountPictures" = [System.Guid] "0482af6c-08f1-4c34-8c90-e17ec98b1e17"
#   "Apps" = [System.Guid] "1e87508d-89c2-42f0-8a7e-645a0f50ca58"
#   "StartMenuAllPrograms" = [System.Guid] "F26305EF-6948-40B9-B255-81453D09C785"
    "CommonStartMenuPlaces" = [System.Guid] "A440879F-87A0-4F7D-B700-0207B966194A"
    "ApplicationShortcuts" = [System.Guid] "A3918781-E5F2-4890-B3D9-A7E54332328C"
    "RoamingTiles" = [System.Guid] "00BCFC5A-ED94-4e48-96A1-3F6217F21990"
    "RoamedTileImages" = [System.Guid] "AAA8D5A5-F1D6-4259-BAA8-78E7EF60835E"
    "Screenshots" = [System.Guid] "b7bede81-df94-4682-a7d8-57a52620b86f"
    "CameraRoll" = [System.Guid] "AB5FB87B-7CE2-4F83-915D-550846C9537B"
    "OneDrive" = [System.Guid] "A52BBA46-E9E1-435f-B3D9-28DAA648C0F6"
    "OneDriveDocuments" = [System.Guid] "24D89E24-2F19-4534-9DDE-6A6671FBB8FE"
    "OneDrivePictures" = [System.Guid] "339719B5-8C47-4894-94C2-D8F77ADD44A6"
    "OneDriveMusic" = [System.Guid] "C3F2459E-80D6-45DC-BFEF-1F769F2BE730"
    "OneDriveCameraRoll" = [System.Guid] "767E6811-49CB-4273-87C2-20F355E1085B"
    "SearchHistory" = [System.Guid] "0D4C3DB6-03A3-462F-A0E6-08924C41B5D4"
    "SearchTemplates" = [System.Guid] "7E636BFE-DFA9-4D5E-B456-D7B39851D8A9"
    "CameraRollLibrary" = [System.Guid] "2B20DF75-1EDA-4039-8097-38798227D5B7"
    "SavedPictures" = [System.Guid] "3B193882-D3AD-4eab-965A-69829D1FB59F"
    "SavedPicturesLibrary" = [System.Guid] "E25B5812-BE88-4bd9-94B0-29233477B6C3"
    "RetailDemo" = [System.Guid] "12D4C69E-24AD-4923-BE19-31321C43A767"
#   "Device" = [System.Guid] "1C2AC1DC-4358-4B6C-9733-AF21156576F0"
    "DevelopmentFiles" = [System.Guid] "DBE8E08E-3053-4BBC-B183-2A7B2B191E59"
    "3DObjects" = [System.Guid] "31C0DD25-9439-4F12-BF41-7FF4EDA38722"
    "Captures" = [System.Guid] "EDC0FE71-98D8-4F4A-B920-C8DC133CB165"
    "LocalDocuments" = [System.Guid] "f42ee2d3-909f-4907-8871-4c22fc0bf756"
    "LocalPictures" = [System.Guid] "0ddd015d-b06c-45d5-8c4c-f59713854639"
    "LocalVideos" = [System.Guid] "35286a68-3c57-41a1-bbb1-0eae73d76c95"
    "LocalMusic" = [System.Guid] "a0c69a99-21c8-4671-8703-7934162fcf1d"
    "LocalDownloads" = [System.Guid] "7d83ee9b-2244-4e70-b1f5-5393042af1e4"
    "RecordedCalls" = [System.Guid] "2f8b40c2-83ed-48ee-b383-a1f157ec6f9a"
    "AppMods" = [System.Guid] "7ad67899-66af-43ba-9156-6aad42e6c596"
    "CurrentAppMods" = [System.Guid] "3db40b20-2a30-4dbe-917e-771dd21dd099"
    "AppDataDesktop" = [System.Guid] "B2C5E279-7ADD-439F-B28C-C41FE1BBF672"
    "AppDataDocuments" = [System.Guid] "7BE16610-1F7F-44AC-BFF0-83E15F2FFCA1"
    "AppDataFavorites" = [System.Guid] "7CFBEFBC-DE1F-45AA-B843-A542AC536CC9"
    "AppDataProgramData" = [System.Guid] "559D40A3-A036-40FA-AF61-84CB430A4D34"
    "LocalStorage" = [System.Guid] "B3EB08D3-A1F3-496B-865A-42B536CDA0EC"
    "DpapiKeys" = [System.Guid] "10C07CD0-EF91-4567-B850-448B77CB37F9"
    "CryptoKeys" = [System.Guid] "B88F4DAA-E7BD-49A9-B74D-02885A5DC765"
    "CredentialManager" = [System.Guid] "915221FB-9EFE-4BDA-8FD7-F78DCA774F87"
    "SystemCertificates" = [System.Guid] "54EED2E0-E7CA-4FDB-9148-0F4247291CFA"
    "ThisPCDesktop" = [System.Guid] "754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5"
    "Podcasts" = [System.Guid] "6E759B19-EC38-4FE6-BF3B-BBE55C9D63C7"
    "PodcastLibrary" = [System.Guid] "8C46A9FF-A54E-4791-8A1C-2D347BF5DF44"
}

#===================================================================================================

$MemberDefinition =
@"
[DllImport("shell32.dll", ExactSpelling = true, PreserveSig = false, SetLastError = false)]
public static extern void SHGetKnownFolderPath([MarshalAs(UnmanagedType.LPStruct)] System.Guid rfid,
    uint dwFlags, System.IntPtr hToken, out System.IntPtr pszPath);
"@

Add-Type -MemberDefinition $MemberDefinition -Name "Shell32" -Namespace "Win32"

#===================================================================================================
