@echo off
setlocal enabledelayedexpansion

set INPUT_FILE=chunk1.lua
set OUTPUT_FILE=output.lua

REM Collect width, height, and data from the first layer's attributes
for /f "tokens=* delims=" %%a in ('type %INPUT_FILE% ^| find "[%]layers"') do (
    set "LINE=%%a"
    set "LINE=!LINE:*{=!"
    set "LINE=!LINE:~1,!"

    if not defined WIDTH (
        for /f "tokens=*" %%b in ('echo !LINE! ^| find "width"') do (
            set "WIDTH=!LINE:*width =!"
            set "WIDTH=!WIDTH:,=!"
            set "WIDTH=!WIDTH: =!"
        )
    )

    if not defined HEIGHT (
        for /f "tokens=*" %%c in ('echo !LINE! ^| find "height"') do (
            set "HEIGHT=!LINE:*height =!"
            set "HEIGHT=!HEIGHT:,=!"
            set "HEIGHT=!HEIGHT: =!"
        )
    )

    if not defined DATA (
        for /f "tokens=* delims=" %%d in ('type %INPUT_FILE% ^| find "[%]data"') do (
            set "LINE=%%d"
            set "LINE=!LINE:*]=!"
            set "LINE=!LINE:~1!"

            set "FLIP_LINE="
            for %%e in (!LINE!) do (
                set "FLIP_LINE=%%e,!FLIP_LINE!"
            )

            set "DATA={!FLIP_LINE:~0,-1!}"
        )
    )

    goto :WRITE_OUTPUT
)

:WRITE_OUTPUT
REM Write the collected width, height, and data to the output file
echo return { > %OUTPUT_FILE%
echo   width = %WIDTH%, >> %OUTPUT_FILE%
echo   height = %HEIGHT%, >> %OUTPUT_FILE%
echo   data = %DATA%, >> %OUTPUT_FILE%
echo } >> %OUTPUT_FILE%

echo Output written to %OUTPUT_FILE%
