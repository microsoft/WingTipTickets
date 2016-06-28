Readme for downloading WTT from Github using the zip file method

There is an issue where if the WTT project has been downloaded through the download zip option that some of the files are corrupted.

These files include:
	\PowerShell\Packages\PrimaryPackage.zip
	\PowerShell\Packages\SecondaryPackage.zip
	\PowerShell\Packages\ProductRecDataGenerator.zip

Follow these steps to repackage these files for use for deployment.

Web App packages
1. Launch Visual Studio 2013/2015
2. Select File > Open Project/Solution 
3. Browse to the downloaded WTT files
4. Open \WebPortal, select WingTipTickets.sln
5. Right click Tenant.mvc, select Build
6. Right click Tenant.mvc, select Publish
7. Click Publish
8. Locate the published PrimaryPackage.zip file
9. Copy the new file to \PowerShell\Packages\
10. Rename the published file to SecondaryPackage.zip
11. Copy the renamed SecondaryPackage.zip file to \PowerShell\Packages\

ProductRedDataGenerator
1. Launch Visual Studio 2013/2015
2. Select File > Open Project/Solution 
3. Browse to \Supporting\ProductRecommendations\DataGenerator
4. Select ProductRecDataGenerator.sln
5. Right click ProjectRecDataGenerator, select Build
6. Browse to the location of the build files
7. Select all the files
8. Right click, select Send To, select compressed (zipped) folder
9. Rename the folder ProductRecDataGenerator.zip
10. Copy the zip file to \PowerShell\Packages\