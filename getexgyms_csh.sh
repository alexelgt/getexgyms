#!/bin/csh

#==== Deal with command line
if ($1 == "-h" || $1 == "help") then
   echo "usage:" $0 "gym_data.csv ex_zones.geojson blocking_zones.geojson"
   echo " * gym_data.csv: file with gyms's data (name,latitude,longitude)"
   echo " * ex_zones.geojson: exported file from overpass-turbo.eu with ex zones"
   echo " * blocking_zones.geojson: exported file from overpass-turbo.eu with blocking zones"

   exit
endif

if ( "$1" == "" ||  "$2" == "" || "$3" == "") then
    echo "Not enough inputs. Check help"

    exit
endif

if (! -f $1 ) then
   echo "first input file not found"

   exit
endif

if (! -f $2 ) then
   echo "second input file not found"

   exit
endif

if (! -f $3 ) then
   echo "third input file not found"

   exit
endif
#== Deal with command line

#==== Set variables
set gym_data = $1
set ex_zones = $2
set blocking_zones = $3
#== Set variables

#==== Set output files names
set gym_filename = `echo $gym_data| sed 's/.csv//g'`

set gym_filename_ex_with_blocked = $gym_filename"_ex_with_blocked.csv" #temporal file
set gym_filename_blocked = $gym_filename"_blocked.csv"
set gym_filename_ex = $gym_filename"_ex.csv"
#== Set output files names

#==== Set output folder
set output_folder = "getexgyms_results"
# If the folder does not exit, create it
if (! -d $output_folder ) then
   mkdir $output_folder
   echo
   echo "Created folder called '"$output_folder"'"
endif
#== Set output folder

#==== Get all gyms inside an ex zone
echo
echo "Get all gyms inside an ex zone"
echo "------------------------------"
osmcoverer -markers=$gym_data -checkcellcenters -excludecellfeatures -skipmarkerless -skipfeatureless $ex_zones

# Rename output file
mv output/markers_within_features.csv $output_folder/$gym_filename_ex_with_blocked #this file includes ex gyms inside a blocking zone

#==== Remove output file created by osmcoverer
rm output/$ex_zones
echo
echo "File 'output/"$ex_zones"' removed (not the input file)"
#== Remove output file created by osmcoverer
#== Get all gyms inside an ex zone

#==== Get all gyms from previous file inside a blocking zone
echo
echo "Get all gyms inside a blocking zone"
echo "------------------------------"
osmcoverer -markers=$output_folder/$gym_filename_ex_with_blocked -checkcellcenters -excludecellfeatures -skipmarkerless -skipfeatureless $blocking_zones

# Rename output file
mv output/markers_within_features.csv $output_folder/$gym_filename_blocked

#==== Remove output file created by osmcoverer
rm output/$blocking_zones
echo
echo "File 'output/"$blocking_zones"' removed (not the input file)"
#== Remove output file created by osmcoverer
#== Get all gyms from previous file inside a blocking zone

# Get all gyms inside an ex zone that are outside of a blocking zone
grep -vf $output_folder/$gym_filename_blocked $output_folder/$gym_filename_ex_with_blocked > $output_folder/$gym_filename_ex #this file includes the true ex gyms

# Delete file with all ex gyms inside a blocking zone
rm $output_folder/$gym_filename_ex_with_blocked

#==== Add header to output files
#sed  -i -e '1i Name,Latitude,Longitude' $output_folder/$gym_filename_blocked
sed -i -e '1s/^/Name,Latitude,Longitude\n/' $output_folder/$gym_filename_blocked
#echo -e "Name,Latitude,Longitude\n$(cat $output_folder/$gym_filename_blocked)" > $output_folder/$gym_filename_blocked
#echo -e "Name,Latitude,Longitude\n$(cat $output_folder/$gym_filename_ex)" > $output_folder/$gym_filename_ex
#== Add header to output files

echo
echo "Output files saved in the folder called '"$output_folder"'"
echo " - The file called '"$gym_filename_ex"' contains all ex gyms"
echo " - The file called '"$gym_filename_blocked"' contains all ex gyms that are inside a blocking zone (they don't have the tag)"
