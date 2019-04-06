#!/bin/bash

#==== Deal with command line
if [ $1 = "-h" ] || [ $1 = "help" ]; then
   echo "usage:" $0 "gyms_data.csv exareas_data.geojson exclusionareas_data.geojson (--noalias --fixencoding --addheader)"
   echo " * gyms_data.csv: file with gyms' data (Name,Latitude,Longitude)"
   echo " * exareas_data.geojson: exported file from overpass-turbo.eu with ex areas"
   echo " * exclusionareas_data.geojson: exported file from overpass-turbo.eu with exclusion areas"
   echo " * --noalias: it'll run the commands with ./osmcoverer"
   echo " * --fixencoding: file with blocked gyms will be encoded to MS-ANSI. Might be needed to upload the file to My Maps"
   echo " * --addheader: add a header row. Needed if you want to upload to My Maps"

   exit
fi

osmcoverer=osmcoverer
for i in "$@"
do
   if [ "$i" = "--noalias" ]; then
      osmcoverer=./osmcoverer #if you change this to other path it'll work
   fi
done

if ! type "$osmcoverer" > /dev/null; then
  echo "Install osmcoverer"

  exit
fi

if [ "$#" -lt 3 ]; then
    echo "Not enough inputs. Check help"

    exit
fi

if [ ! -f $1 ]; then
   echo $1 "not found"
   exit
elif [ ${1: -4} != ".csv" ]; then
   echo $1 "is not a csv file"
   exit
fi

if [ ! -f $2 ]; then
   echo $2 "not found"
   exit
elif [ ${2: -8} != ".geojson" ]; then
   echo $2 "is not a geojson file"
   exit
fi

if [ ! -f $3 ]; then
   echo $3 "not found"
   exit
elif [ ${3: -8} != ".geojson" ]; then
   echo $3 "is not a geojson file"
   exit
fi

fixencoding=false
for i in "$@"
do
   if [ "$i" = "--fixencoding" ]; then
      fixencoding=true
   fi
done

addheader=false
for i in "$@"
do
   if [ "$i" = "--addheader" ]; then
      addheader=true
   fi
done
#== Deal with command line

#==== Set variables
gym_data=$1
ex_areas=$2
exclusion_areas=$3
#== Set variables

#==== Set output files names
gym_filename=`echo $(basename $gym_data)| sed 's/.csv//g'`

gym_filename_ex_with_blocked=$gym_filename"_ex_with_blocked.csv" #temporal file
gym_filename_blocked=$gym_filename"_blocked.csv"
gym_filename_ex=$gym_filename"_ex.csv"
#== Set output files names

#==== Set output folder
output_folder="getexgyms_results"
# If the folder does not exit, create it
if [ ! -d $output_folder ]; then
   mkdir $output_folder
   echo
   echo "Created folder called '"$output_folder"'"
fi
#== Set output folder

#==== Get all gyms inside an ex area
echo
echo "Get all gyms inside an ex area"
echo "------------------------------"
$osmcoverer -markers=$gym_data -checkcellcenters -excludecellfeatures -skipmarkerless -skipfeatureless $ex_areas

# Rename output file
mv output/markers_within_features.csv $output_folder/$gym_filename_ex_with_blocked #this file includes ex gyms inside an exclusion area

#==== Remove output file created by osmcoverer
rm output/$(basename $ex_areas)
echo
echo "File 'output/"$ex_areas"' removed (not the input file)"
#== Remove output file created by osmcoverer
#== Get all gyms inside an ex area

#==== Get all gyms from previous file inside an exclusion area
echo
echo "Get all gyms inside an exclusion area"
echo "------------------------------"
$osmcoverer -markers=$output_folder/$gym_filename_ex_with_blocked -checkcellcenters -excludecellfeatures -skipmarkerless -skipfeatureless $exclusion_areas

# Rename output file
mv output/markers_within_features.csv $output_folder/$gym_filename_blocked

#==== Remove output file created by osmcoverer
rm output/$(basename $exclusion_areas)
echo
echo "File 'output/"$exclusion_areas"' removed (not the input file)"
#== Remove output file created by osmcoverer
#== Get all gyms from previous file inside an exclusion area

if [ -s $output_folder/$gym_filename_blocked ]
then
   # Get all gyms inside an ex area that are outside of an exclusion area
   grep -vf $output_folder/$gym_filename_blocked $output_folder/$gym_filename_ex_with_blocked > $output_folder/$gym_filename_ex #this file includes the true ex gyms

   # Delete file with all ex gyms inside an exclusion area
   rm $output_folder/$gym_filename_ex_with_blocked
else
   # If there are not blocked gyms just rename the file
   mv $output_folder/$gym_filename_ex_with_blocked $output_folder/$gym_filename_ex
fi

#==== Add header to output files
if [ $addheader = true ]; then
   echo -e "Name,Latitude,Longitude\n$(cat $output_folder/$gym_filename_blocked)" > $output_folder/$gym_filename_blocked
   echo -e "Name,Latitude,Longitude\n$(cat $output_folder/$gym_filename_ex)" > $output_folder/$gym_filename_ex
   echo
   echo "Header added to output files"
fi
#== Add header to output files

#==== Change encoder of the file gym_filename_blocked
# NOTE: there seems to be a bug in osmcoverer regarding text encoding.
# If this change is not done and you upload the file to Google My Maps, some names won't show correctly
# This happens when you use as input the output (markers_within_features.csv) of the previous osmcoverer run
if [ $fixencoding = true ]; then
   iconv -f utf-8 -t MS-ANSI $output_folder/$gym_filename_blocked > $output_folder/temp_file
   rm $output_folder/$gym_filename_blocked
   mv $output_folder/temp_file $output_folder/$gym_filename_blocked
   echo
   echo "Changed encoding of file called '"$gym_filename_blocked"'"
fi
#== Change encoder of the file gym_filename_blocked

echo
echo "Output files saved in the folder called '"$output_folder"'"
echo " - The file called '"$gym_filename_ex"' contains all ex gyms"
echo " - The file called '"$gym_filename_blocked"' contains all ex gyms that are inside an exclusion area (they don't have the tag)"
