# **Get EX gyms**
This bash script runs [osmcoverer](https://github.com/MzHub/osmcoverer) in such a way that it obtains EX gyms and "EX gyms" that are in a blocking zone.

## **Index**
* [Prerequisites](#prerequisites)
    * [Windows](#windows-prerequisites)
    * [macOS or Linux](#macos-or-linux-prerequisites)
* [Set up the script](#set-up-the-script)
    * [Windows](#windows-set-up)
    * [macOS or Linux](#macos-or-linux-set-up)
* [How to use](#how-to-use)
    * [Flags](#flags)
        * [--noalias](#--noalias)
        * [--fixencoding](#--fixencoding)
        * [--addheader](#--addheader)
* [Run script with the example data](#run-script-with-the-example-data)
    * [Windows](#windows-run-example)
    * [macOS or Linux](#macos-or-linux-set-up)

## **Prerequisites**
You need to have [osmcoverer](https://github.com/MzHub/osmcoverer) on your computer and Windows' users also need to have [Cygwin](https://cygwin.com).

### **Windows prerequisites**
1. Go to [Cygwin](https://cygwin.com) and install it.

2. Open **Cygwin Terminal** (this will create some folders in **C:\\cygwin\\home**).

3. Go to [osmcoverer releases](https://github.com/MzHub/osmcoverer/releases), download the file for Windows and extract it.

4. Copy (or move) the file called **osmcoverer.exe** to **C:\\cygwin\\home\\\<user>** (or any subfolder).

Now you have Cygwin and osmcoverer set up.

### **macOS or Linux prerequisites**
1. Go to [osmcoverer releases](https://github.com/MzHub/osmcoverer/releases), download the file for macOS or Linux and extract it.

2. Open the Terminal app an go to the folder where you have extracted the file (```cd /path_to_the_folder```).

3. Type ```chmod 755 osmcoverer```

4. Type ```mv osmcoverer /usr/local/bin/```

Now you have osmcoverer set up.

## **Set up the script**

### **Windows set up**
1. Clone or download this repo. Then move the files to **C:\\cygwin\\home\\\<user>** (or any subfolder). The file called **<span>getexgyms.sh</span>** has to be in the same folder as **osmcoverer.exe**.

### **macOS or Linux set up**
1. Clone or download this repo. Then move the files to the folder you want to have the output files.

## **How to use**
To run the code type:

```./getexgyms.sh gyms_data.csv exzones_data.geojson blockingzones_data.geojson (--noalias --fixencoding --addheader)```

Where:
* **gyms_data.csv:** file with gyms's data.
    * **Estructure of the csv file:** Name,Latitude,Longitude. **(Do NOT include a header row)**

* **exzones_data.geojson:** exported file from overpass-turbo.eu with ex zones

* **blockingzones_data.geojson:** exported file from overpass-turbo.eu with blocking zones

* **--noalias:** it'll run the commands with ./osmcoverer

* **--fixencoding:** file with blocked gyms will be encoded to MS-ANSI. Might be needed to upload the file to My Maps

* **--addheader:** add a header row. Needed if you want to upload to My Maps

### **Flags**
#### **--noalias**
If this flag is not included then the script will run **osmcoverer** simply as ```osmcoverer```. If you moved the file to the folder /usr/local/bin (in macOS or Linux) or if you wrote an alias in the file .bashrc (or equivalent) the script should find osmcoverer.

If this flag is included then the script will run **osmcoverer** as ```./osmcoverer```. This implies that **osmcoverer** has to be in the same folder as **<span>getexgyms.sh</span>**.

If you followed the instructions for Windows users, you need to include this flag.

#### **--fixencoding**
This flag might be needed if you want to upload the file with blocked gym to My Maps. Otherwise it might happend what is shown in this picture:

![hola](assets/example_of_wrong_encoding.png)

#### **--addheader**
This flag will include a row at the begining of the output files with the text
> Name,Latitude,Longitude

This is needed if you want to upload the ouput files to My Maps. If you don't do this, the first row of the data will be used as a header.

## **Run script with the example data**
### **Windows run example**
1. In **Cygwin Terminal** type ```cd /home/<user>``` (or any subfolder).

2. Type ```./getexgyms.sh example_data/gymsAlcoSanse.csv example_data/madrid_exzones.geojson example_data/madrid_blockingzones.geojson --noalias```

The flag **--noalias** runs the code assuming that **osmcoverer** is in the same folder as **<span>getexgyms.sh</span>**
### **macOS or Linux run example**

1. Open the Terminal app an go to the folder where you want to have the output files (```cd /path_to_the_folder```).

2. Type ```./getexgyms.sh example_data/gymsAlcoSanse.csv example_data/madrid_exzones.geojson example_data/madrid_blockingzones.geojson```

