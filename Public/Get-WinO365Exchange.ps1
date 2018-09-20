function Get-WinO365Exchange {
    [CmdletBinding()]
    param()
    $Data = [ordered] @{}
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeMailBoxes"
    $Data.O365ExchangeMailBoxes = Get-Mailbox -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeMailUsers"
    $Data.O365ExchangeMailUsers = Get-MailUser -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeUsers"
    $Data.O365ExchangeUsers = Get-User -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeRecipients"
    $Data.O365ExchangeRecipients = Get-Recipient -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeRecipientsPermissions"
    $Data.O365ExchangeRecipientsPermissions = Get-RecipientPermission -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeGroupsDistribution"
    $Data.O365ExchangeGroupsDistribution = Get-DistributionGroup -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeGroupsDistributionDynamic"
    $Data.O365ExchangeGroupsDistributionDynamic = Get-DynamicDistributionGroup -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeGroupsDistributionMembers"
    $Data.O365ExchangeGroupsDistributionMembers = Invoke-Command -ScriptBlock {
        $GroupMembers = @()
        foreach ($Group in $Data.O365ExchangeGroupsDistribution) {
            $Object = Get-DistributionGroupMember -Identity $Group.PrimarySmtpAddress -ResultSize unlimited
            $Object | Add-Member -MemberType NoteProperty -Name "GroupGUID" -Value $Group.GUID
            $Object | Add-Member -MemberType NoteProperty -Name "GroupPrimarySmtpAddress" -Value $Group.PrimarySmtpAddress
            $Object | Add-Member -MemberType NoteProperty -Name "GroupIdentity" -Value $Group.Identity
            $GroupMembers += $Object
        }
        return $GroupMembers
    }
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeMailboxesJunk"
    $Data.O365ExchangeMailboxesJunk = Invoke-Command -ScriptBlock {
        $Output = @()
        foreach ($Mailbox in $Data.O365ExchangeMailBoxes) {
            if ($Mailbox.PrimarySmtpAddress -ne $null) {
                #Write-Verbose "O365ExchangeMailboxesJunk - $($Mailbox.PrimarySmtpAddress)"
                $Object = Get-MailboxJunkEmailConfiguration -Identity $Mailbox.PrimarySmtpAddress -ResultSize unlimited
                if ($Object) {
                    $Object | Add-Member -MemberType NoteProperty -Name "MailboxPrimarySmtpAddress" -Value $Mailbox.PrimarySmtpAddress
                    $Object | Add-Member -MemberType NoteProperty -Name "MailboxAlias" -Value $Mailbox.Alias
                    $Object | Add-Member -MemberType NoteProperty -Name "MailboxGUID" -Value $Mailbox.GUID
                    $Output += $Object
                }
            }
        }
        return $Output
    }
    #

    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeContacts"
    $Data.O365ExchangeContacts = Get-Contact -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeContactsMail"
    $Data.O365ExchangeContactsMail = Get-MailContact -ResultSize unlimited
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeMailboxesRooms"
    $Data.O365ExchangeMailboxesRooms = $Data.O365ExchangeMailBoxes | Where { $_.RecipientTypeDetails -eq 'RoomMailbox' }
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeMailboxesEquipment"
    $Data.O365ExchangeMailboxesEquipment = $Data.O365ExchangeMailBoxes | Where { $_.RecipientTypeDetails -eq 'EquipmentMailbox' }
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeRoomsCalendarProcessing"
    $Data.O365ExchangeRoomsCalendarProcessing = Invoke-Command -ScriptBlock {
        $Output = @()
        foreach ($Mailbox in $Data.O365ExchangeMailboxesRooms) {
            $Object = Get-CalendarProcessing -Identity $Mailbox.PrimarySmtpAddress -ResultSize unlimited
            if ($Object) {
                $Object | Add-Member -MemberType NoteProperty -Name "MailboxPrimarySmtpAddress" -Value $Mailbox.PrimarySmtpAddress
                $Object | Add-Member -MemberType NoteProperty -Name "MailboxAlias" -Value $Mailbox.Alias
                $Object | Add-Member -MemberType NoteProperty -Name "MailboxGUID" -Value $Mailbox.GUID
                $Output += $Object
            }
        }

    }
    Write-Verbose "Get-WinO365Exchange - Getting O365ExchangeEquipmentCalendarProcessing"
    $Data.O365ExchangeEquipmentCalendarProcessing = Invoke-Command -ScriptBlock {
        $Output = @()
        foreach ($Mailbox in $Data.O365ExchangeMailboxesEquipment) {
            $Object = Get-CalendarProcessing -Identity $Mailbox.PrimarySmtpAddress -ResultSize unlimited
            if ($Object) {
                $Object | Add-Member -MemberType NoteProperty -Name "MailboxPrimarySmtpAddress" -Value $Mailbox.PrimarySmtpAddress
                $Object | Add-Member -MemberType NoteProperty -Name "MailboxAlias" -Value $Mailbox.Alias
                $Object | Add-Member -MemberType NoteProperty -Name "MailboxGUID" -Value $Mailbox.GUID
                $Output += $Object
            }
        }
    }
    return $Data
}

