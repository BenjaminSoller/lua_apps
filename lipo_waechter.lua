-- Globale Variablen
local sensorId = 0 -- Standard ID für den Spannungssensor
local cellCount = 4 -- Anzahl der Zellen (S)
local minVoltage = 3.2 -- Minimalspannung pro Zelle
local maxVoltage = 4.2 -- Maximalspannung pro Zelle
local alarmThreshold = 20 -- Alarm ab 20%
local voltage = 0 -- Gemessene Spannung
local percent = 0 -- Berechneter Prozentsatz

-- Funktion zur Berechnung des Ladezustands
local function calculatePercentage(voltage)
    local totalMaxVoltage = cellCount * maxVoltage
    local totalMinVoltage = cellCount * minVoltage
    local totalVoltageRange = totalMaxVoltage - totalMinVoltage
    local voltageRange = voltage - totalMinVoltage

    if voltageRange < 0 then
        voltageRange = 0
    end
    
    return math.min(100, (voltageRange / totalVoltageRange) * 100)
end

-- Funktion zur Darstellung der Batterieanzeige
local function drawBattery(x, y, w, h, percent)
    local color
    if percent > 75 then
        color = lcd.RGB(0, 255, 0) -- Grün
    elseif percent > 50 then
        color = lcd.RGB(255, 255, 0) -- Gelb
    elseif percent > 25 then
        color = lcd.RGB(255, 165, 0) -- Orange
    else
        color = lcd.RGB(255, 0, 0) -- Rot
    end

    lcd.setColor(color)
    local filledHeight = math.floor(h * (percent / 100))
    lcd.drawFilledRectangle(x, y + (h - filledHeight), w, filledHeight)
    lcd.setColor(lcd.RGB(255, 255, 255)) -- Zurücksetzen auf Weiß
    lcd.drawRectangle(x, y, w, h)
end

-- Hauptloop-Funktion
local function loop()
    -- Spannung vom Telemetrie-Sensor abrufen
    voltage = getValue(sensorId)
    
    if voltage == nil then
        voltage = 0 -- Sicherheitsvorkehrung, falls kein Sensorwert verfügbar ist
    end

    -- Berechne Prozentsatz
    percent = calculatePercentage(voltage)

    -- Anzeige auf dem Bildschirm
    lcd.clear()
    lcd.drawText(10, 10, "Akkustatus: " .. math.floor(percent) .. "%", FONT_MAXI)
    drawBattery(10, 40, 50, 100, percent)

    -- Überprüfe, ob ein Alarm ausgelöst werden soll
    if percent <= alarmThreshold then
        playFile("/SOUNDS/de/alarm.wav")
    end
end

-- Initialisierung der App
local function init()
    -- Hier könntest du Einstellungen oder Initialisierungen hinzufügen
end

-- Konfigurationsmenü
local function initForm()
    form.addRow(2)
    form.addLabel({label="Zellenanzahl (S)", width=220})
    form.addIntbox(cellCount, 1, 12, 4, 0, 1, function(value) cellCount = value end)

    form.addRow(2)
    form.addLabel({label="Alarmwert (%)", width=220})
    form.addIntbox(alarmThreshold, 5, 100, 20, 0, 1, function(value) alarmThreshold = value end)

    form.addRow(2)
    form.addLabel({label="Spannungssensor-ID", width=220})
    form.addIntbox(sensorId, 0, 255, 0, 0, 1, function(value) sensorId = value end)
end

-- Registrierung der init und loop Funktionen
return { init=init, loop=loop, initForm=initForm }
