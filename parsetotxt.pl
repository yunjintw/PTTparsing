use strict;
use Date::Parse;
use Cwd;
use Scalar::Util;

##Loading info of list.txt
    my %AID2date;
    my %AID2author;
    my %AID2title;

open inList, "<list.txt";
while(<inList>)
{
    chomp($_);
    my @temp = split(/\t/, $_);
    $AID2date{$temp[0]}   = $temp[1];
    $AID2author{$temp[0]} = $temp[2];
    $AID2title{$temp[0]}  = $temp[3];
}
close inList;
##end of loading info of list.txt

my @folder = split /\//, getcwd();  # get the current folder path


open  Fout, ">>".$folder[$#folder].".txt";
print Fout "articleID\tauthorName\tboardName\tarticleTitle\tarticleType\tpostDate\tpostTime\tinnerDate\tinnerTime\ttwitCounter\ttwitterID\ttwitType\ttwitDate\ttwitTime\ttwit\n";
close Fout;

## read all fileNames ##
my @textNames = <*.text.txt>;
## end of read all fileNames ##


foreach my $fileName (@textNames)
{
    ## �}�l�B�z����
    my $authorName    = "";                ## 
    my $boardName     = "";                ## 
    my $articleTitle  = "";                ## 
    my $articleType   = 0 ;                ## 
    my $postDate      = "";                ## �ɮײ��ͮɶ�(�@�̫��Uctrl+P)���@�������ɶ�
                                           ## ����榡�� mm/dd/yyyy
    my $postTime      = "";                ## �ɮײ��ͮɶ�(�@�̫��Uctrl+P)���@�������ɶ�
                                           ## �ɶ��榡�� hh:mm:ss
    my $innerDate     = "";                ## �峹���m����A�쬰�۰ʲ��͡A�@�̦��i��post�峹����H�j�gE���O��ʭק�
    my $innerTime     = "";                ## �峹���m�ɶ��A�쬰�۰ʲ��͡A�@�̦��i��post�峹����H�j�gE���O��ʭק�
    my $commentOrder  = 0 ;                ## ����ǡA�p�G�o�g�峹�S������AcommentOrder�N�|�O�u0�v
    my $year          = 2000;
    
    my $articleID     = $fileName;
    $articleID        =~ s/.text.txt//;
    
    my $lineCounter  = 1;
    
    open TEXTFILE, "<$fileName";
    while(<TEXTFILE>)
    {
        if($lineCounter == 1)
        {
            #my @words = split / /, $_;
            #$authorName = $words[1];
            $authorName = $AID2author{$articleID};
            $boardName = $folder[$#folder];
        }
        
        elsif($lineCounter == 2)
        {
            #my $line      = $_;
            my $substring    = "Re:";
            #$articleTitle = substr($_, 6);
            $articleTitle = $AID2title{$articleID};
            $articleTitle =~ s/'/\\'/g;
            if(index($articleTitle, $substring) == 0)
            {
                $articleType = 1;
                $articleTitle = substr($articleTitle, 4);
            }
        }
        
        elsif($lineCounter == 3)
        {
            my $line = $_;
            chomp($line);
            $line =~ s/  / /g;
            my @Time = split/ /, $line;
            my @Mon2 = split(/\//, $AID2date{$articleID});
            
            if(Scalar::Util::looks_like_number($Time[5]) == 1)
            {
                $innerDate = "$Mon2[0]/$Mon2[1]/$Time[5]";
                $innerTime = "$Time[4]";
                $year = $Time[5];                
            }
            else
            {
                $innerDate = "$Mon2[0]/$Mon2[1]/$year";
                $innerTime = "00:00:00";
            }
            
            
        }
        $lineCounter++;
        
        last if ($lineCounter >= 4);
        my $MS = substr($fileName, 2, 10);
        $postDate = ((localtime($MS))[4] + 1)."/".(localtime($MS))[3]."/".((localtime($MS))[5] + 1900);
        $postTime = (localtime($MS))[2].":".(localtime($MS))[1].":".(localtime($MS))[0];
    }
        
    ## �}�l�B�z����    
    $fileName       =~ s/.text.txt/.push.txt/;
    my $twitCounter = 0;
    my $nopush      = 0;
    
    open(PUSHFILE, $fileName) or $nopush = 1;
    if($nopush == 1)
        {
        	open  Fout, ">>".$folder[$#folder].".txt";
        	print Fout "$articleID\t$authorName\t$boardName\t$articleTitle\t$articleType\t$postDate\t$postTime\t$innerDate\t$innerTime\t$commentOrder\t\t\t\t\t\n";
        	close Fout;
        	close TEXTFILE;
        }
    elsif($nopush == 0)
        {  
          binmode(PUSHFILE);
          open PUSHFILE, "<$fileName";
          while(<PUSHFILE>)
              {       
              	$twitCounter++;
              	my @words = split /\t/, $_;
              	my $date = $words[0];
              	my $twitterID = $words[2];
              	my $twitType = $words[3];
              	my $twit = $words[4];

                $twitType = (
                             "��" => '1',
                             "�N" => '-1',
                             "��"  => '0'
                            );

              	my @sDate = split(/[ \/:]/, $words[0]);
              	my $twitDate = "";                                      ## ������
              	my $twitTime = "";                                      ## ����ɶ�
              	
              	my $MS = substr($fileName, 2, 10);
              	$twitDate = $sDate[0]."/".$sDate[1]."/".((localtime($MS))[5] + 1900);           
              	$twitTime = $sDate[2].":".$sDate[3].":00";
              	
              	open  Fout, ">>".$folder[$#folder].".txt";
              	print Fout "$articleID\t$authorName\t$boardName\t$articleTitle\t$articleType\t$postDate\t$postTime\t$innerDate\t$innerTime\t$twitCounter\t$twitterID\t$twitType\t$twitDate\t$twitTime\t$twit";
              }
          close PUSHFILE;
          close TEXTFILE;               
        }         
}