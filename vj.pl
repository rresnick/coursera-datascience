#!/usr/bin/perl
#
#
use CGI::Carp qw(fatalsToBrowser);
use HTTP::Cookies;
use LWP::UserAgent;
use Time::Local;

print "Content-type: text/html\n\n";
print "<html><head></head><body>\n";
print "<center><H1>Stuck in AP \@NVC</H1>\n";
print "<i>aka \"Ron's List\"</i><br>\n";
print "Current server time is ";
print localtime() . "<br></center>\n";
print "All data is taken from <a href=\"http://www.visajourney.com\">VisaJourney</a> timelines. Data here is <i>only</i> as accurate as that in VJ timelines.<br>\n";
print "This list pulls the most recent 500 records from VJ database sorted by NVC-Received field. Only records >10 days in NVC are considered, shorter durations are discarded.<br>\n";
print "Use at your own risk. No warranties implied or assumed.<br>\n";
print "Feedback: <a href=\"mailto:resnick.ron\@gmail.com\">Email</a><br>\n";
$cookie_jar = HTTP::Cookies->new;
$ua=LWP::UserAgent->new;
$cookie_jar->set_cookie(1,"myrows","500","/timeline/","www.visajourney.com");
$ua->cookie_jar($cookie_jar);
$result_code=$ua->get('http://www.visajourney.com/timeline/k1list.php?cfl=&op1=b&op2=d&op3=1&op4=1&op5=&op6=All&op7=All&dfile=No');

$result=$result_code->content;
@result = split("\n",$result);
$i =0;
foreach $r (@result)
{ 
  $userid->{$i} = $1 if $r =~ /showuser=(\d*).*\>(.*?)\</;
  $names->{$i} = $1 if $r =~ /(\<a href.*showuser.*\<\/a\>)/;
  $country->{$i} = $1 if $r =~ /Country.*\>(.*)\<\/a\>/;
  $svcCenter->{$i} = $1 if $r =~ /Service Center.*\>(.*)\<\/td\>/;
  $nvcIn->{$i} = $1 if $r =~ /NVC received.*\>(.*)\<\/td\>/;
  $nvcOut->{$i} = $1 if $r =~ /NVC forwarded.*\>(.*)\<\/td\>/;
  $conReceived->{$i} = $1 if $r =~ /Consulate Received.*\>(.*)\<\/td\>/;
  $packet3Received->{$i} = $1 if $r =~ /Packet 3 received.*\>(.*)\<\/td\>/;
  $packet3Returned->{$i} = $1 if $r =~ /Packet 3 returned.*\>(.*)\<\/td\>/;
  $packet4Received->{$i} = $1 if $r =~ /Packet 4 received.*\>(.*)\<\/td\>/;
  $interviewDate->{$i} = $1 if $r =~ /Interview Date.*\>(.*)\<\/td\>/;
  $visaReceived->{$i} = $1 if $r =~ /Date Visa Received.*\>(.*)\<\/td\>/;
  $usEntry->{$i++} = $1 if $r =~ /US entry.*\>(.*)\<\/td\>/;
}
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime();
$today = sprintf("%4d-%02d-%02d",$year+1900,$mon+1,$mday);
#$today = timegm(0,0,0,$mday,$mon,$year);
foreach $k (sort {$a <=> $b} keys %$userid)
{
	if ($nvcOut->{$k} =~ /\d\d/)
	{
		$x="$nvcIn->{$k} $nvcOut->{$k}";
		$x =~ /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d\d\d)-(\d\d)-(\d\d)/;
		$inout->{$k} = (timegm(0,0,0,$6,$5-1,$4) - timegm(0,0,0,$3,$2-1,$1))/(60*60*24);
	} else {
		$endtime = $today;
		$endtime = $usEntry->{$k} if $usEntry->{$k} =~ /\d\d/;
		$endtime = $visaReceived->{$k} if $visaReceived->{$k} =~ /\d\d/;
		$endtime = $interviewDate->{$k} if $interviewDate->{$k} =~ /\d\d/;
		$endtime = $packet4Received->{$k} if $packet4Received->{$k} =~ /\d\d/;
		$endtime = $packet3Returned->{$k} if $packet3Returned->{$k} =~ /\d\d/;
		$endtime = $packet3Received->{$k} if $packet3Received->{$k} =~ /\d\d/;
		$endtime = $conReceived->{$k} if $conReceived->{$k} =~ /\d\d/;
		$x="$nvcIn->{$k} $endtime";
		$x =~ /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d\d\d)-(\d\d)-(\d\d)/;
		$delta = (timegm(0,0,0,$6,$5-1,$4)- timegm(0,0,0,$3,$2-1,$1))/(60*60*24);
		if ($endtime == $today)
		{
			$stuck->{$k} = $delta;
		} else {
			$leftover->{$k} = $delta;
		}
	}
}
$suminout =0;
$countinout =0;
$suminout30 =0;
$countinout30 =0;
foreach $k (keys %$inout)
{
	next if $inout->{$k} < 10;
	$suminout += $inout->{$k};
	$countinout++;
	if ($inout->{$k} > 30)
	{
		$suminout30 += $inout->{$k};
		$countinout30++;
	}
	$htmlstring = "<tr>\n";
	$htmlstring .= "<td>$names->{$k}</td>\n"; 
	$htmlstring .= "<td>$country->{$k}</td>\n"; 
	$htmlstring .= "<td>$svcCenter->{$k}</td>\n"; 
	$htmlstring .= "<td>$nvcIn->{$k}</td>\n"; 
	$htmlstring .= "<td>$nvcOut->{$k}</td>\n"; 
	$htmlstring .= "<td>$inout->{$k}</td>\n"; 
	#print "<td>$conReceived->{$k}</td>\n"; 
	#print "<td>$packet3Received->{$k}</td>\n"; 
	#print "<td>$packet3Returned->{$k}</td>\n"; 
	#print "<td>$packet4Received->{$k}</td>\n"; 
	#print "<td>$interviewDate->{$k}</td>\n"; 
	#print "<td>$visaReceived->{$k}</td>\n"; 
	#print "<td>$usEntry->{$k}</td>\n"; 
	$htmlstring .= "</tr>\n";
	push (@{$inouthtml->{$inout->{$k}}},$htmlstring);
}
print "<H1>K1 Entered and Exited NVC</H1>\n";
$avginout = sprintf ("%.2f",$suminout/$countinout);
print "<i>$countinout records, average NVC duration $avginout</i><br>\n";
$avginout30 = sprintf ("%.2f",$suminout30/$countinout30);
print "<i>$countinout30 records>30 days, average NVC duration for those over 30days: $avginout30</i><br>\n";
print "<table border=\"1\">\n";
#print "<tr><td>Seq</td><td>ID</td><td>Name</td><td>Country</td><td>Service Center</td><td>NVC In</td><td>NVC Out</td><td>Consulate Received</td><td>Packet 3 Received</td><td>Packet 3 Returned</td><td>Packet 4 Received</td><td>Interview</td><td>Visa</td><td>US Entry</td></tr>";
print "<tr><td>Name</td><td>Country</td><td>Service Center</td><td>NVC In</td><td>NVC Out</td><td>Days at NVC</td></tr>";
foreach $k (reverse sort {$a <=> $b} keys %$inouthtml)
{
	foreach $s (@{$inouthtml->{$k}})
	{
		print $s;
	}
}

$sumstuck =0;
$countstuck =0;
$sumstuck30 =0;
$countstuck30 =0;
foreach $k (keys %$stuck)
{
	next if $stuck->{$k} < 10;
	$sumstuck += $stuck->{$k};
	$countstuck++;
	if ($stuck->{$k} > 30)
	{
		$sumstuck30 += $stuck->{$k};
		$countstuck30++;
	}
	$htmlstring = "<tr>\n";
	$htmlstring .= "<td>$names->{$k}</td>\n"; 
	$htmlstring .= "<td>$country->{$k}</td>\n"; 
	$htmlstring .= "<td>$svcCenter->{$k}</td>\n"; 
	$htmlstring .= "<td>$nvcIn->{$k}</td>\n"; 
	$htmlstring .= "<td>$nvcOut->{$k}</td>\n"; 
	$htmlstring .= "<td>$stuck->{$k}</td>\n"; 
	#print "<td>$conReceived->{$k}</td>\n"; 
	#print "<td>$packet3Received->{$k}</td>\n"; 
	#print "<td>$packet3Returned->{$k}</td>\n"; 
	#print "<td>$packet4Received->{$k}</td>\n"; 
	#print "<td>$interviewDate->{$k}</td>\n"; 
	#print "<td>$visaReceived->{$k}</td>\n"; 
	#print "<td>$usEntry->{$k}</td>\n"; 
	$htmlstring .= "</tr>\n";
	push (@{$stuckhtml->{$stuck->{$k}}},$htmlstring);
}
print "</table>\n";
print "<H1>K1 Still at NVC</H1>\n";
$avgstuck = sprintf ("%.2f",$sumstuck/$countstuck);
$avgstuck30 = sprintf ("%.2f",$sumstuck30/$countstuck30);
print "<i>$countstuck records, average time still waiting at NVC $avgstuck</i><br>\n";
print "<i>$countstuck30 records>30 days, average NVC stuck-time for those over 30days: $avgstuck30</i><br>\n";
print "<table border=\"1\">\n";
#print "<tr><td>Seq</td><td>ID</td><td>Name</td><td>Country</td><td>Service Center</td><td>NVC In</td><td>NVC Out</td><td>Consulate Received</td><td>Packet 3 Received</td><td>Packet 3 Returned</td><td>Packet 4 Received</td><td>Interview</td><td>Visa</td><td>US Entry</td></tr>";
print "<tr><td>Name</td><td>Country</td><td>Service Center</td><td>NVC In</td><td>NVC Out</td><td>Stuck at NVC</td></tr>";
foreach $k (reverse sort {$a <=> $b} keys %$stuckhtml)
{
	foreach $s (@{$stuckhtml->{$k}})
	{
		print $s;
	}
}

print "</table>\n";
print "<H1>K1 No NVC Left Date, But Later Date in Timeline</H1>\n";
print "<table border=\"1\">\n";
print "<tr><td>Name</td><td>Country</td><td>Service Center</td><td>NVC In</td><td>NVC Out</td><td>Consulate Received</td><td>Packet 3 Received</td><td>Packet 3 Returned</td><td>Packet 4 Received</td><td>Interview</td><td>Visa</td><td>US Entry</td><td>Delta</td></tr>";
#print "<tr><td>Seq</td><td>ID</td><td>Name</td><td>Country</td><td>Service Center</td><td>NVC In</td><td>NVC Out</td><td>Stuck at NVC</td></tr>";
foreach $k (keys %$leftover)
{
	next if $leftover->{$k} < 10;
	$htmlstring = "<tr>\n";
	$htmlstring .= "<td>$names->{$k}</td>\n"; 
	$htmlstring .= "<td>$country->{$k}</td>\n"; 
	$htmlstring .= "<td>$svcCenter->{$k}</td>\n"; 
	$htmlstring .= "<td>$nvcIn->{$k}</td>\n"; 
	$htmlstring .= "<td>$nvcOut->{$k}</td>\n"; 
	$htmlstring .= "<td>$conReceived->{$k}</td>\n"; 
	$htmlstring .= "<td>$packet3Received->{$k}</td>\n"; 
	$htmlstring .= "<td>$packet3Returned->{$k}</td>\n"; 
	$htmlstring .= "<td>$packet4Received->{$k}</td>\n"; 
	$htmlstring .= "<td>$interviewDate->{$k}</td>\n"; 
	$htmlstring .= "<td>$visaReceived->{$k}</td>\n"; 
	$htmlstring .= "<td>$usEntry->{$k}</td>\n"; 
	$htmlstring .= "<td>$leftover->{$k}</td>\n"; 
	$htmlstring .= "</tr>\n";
	push (@{$leftoverhtml->{$leftover->{$k}}},$htmlstring);
}
foreach $k (reverse sort {$a <=> $b} keys %$leftoverhtml)
{
	foreach $s (@{$leftoverhtml->{$k}})
	{
		print $s;
	}
}

print "</table>\n";
print "</body></html>\n";