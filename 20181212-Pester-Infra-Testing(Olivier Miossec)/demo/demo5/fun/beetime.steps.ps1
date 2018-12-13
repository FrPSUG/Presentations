Given "Le Meetup c'est Bien" { 
    $true | Should be $true
 }
When "The Meetup End" { 
    $true | Should be $true
}
Then "I Invite you to drink a Beer"  { 
    $TheBarIsOpen = $true
    $TheBarIsOpen| Should be $true

}