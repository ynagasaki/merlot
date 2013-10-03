#!/bin/sh

if [ -d "./export/mac/neko/bin/merlot.app" ]; then
	echo "app exists. gonna copy the saved level data... ";
	for f in $( ls ./export/mac/neko/bin/merlot.app/Contents/Resources/assets/lvls ); do
		if [ -f "./assets/lvls/$f" ]; then
			DATE_HERE=$( stat -f %m ./assets/lvls/$f );
			DATE_THERE=$( stat -f %m ./export/mac/neko/bin/merlot.app/Contents/Resources/assets/lvls/$f );

			echo "  date in app: $DATE_HERE";
			echo "  date in proj: $DATE_THERE";

			if [ $DATE_HERE -le $DATE_THERE ]; then
				echo "  * overwriting $f from app to proj.";
				cp ./export/mac/neko/bin/merlot.app/Contents/Resources/assets/lvls/$f ./assets/lvls/$f;
			else
				echo "  * newer version in proj; not copying.";
			fi
		else
			echo "  * copying $f from app to proj.";
			cp ./export/mac/neko/bin/merlot.app/Contents/Resources/assets/lvls/$f ./assets/lvls/$f;
		fi
	done
else
	echo "app doesn't exist.";
fi

echo "cleaning build.";
rm -rf ./export/mac;

echo "building."
openfl test neko;