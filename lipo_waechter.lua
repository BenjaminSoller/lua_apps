-- Globale Variablen
local sensorId = 0 -- ID des ausgewählten Spannungssensors
local cellCount = 4 -- Standard Zellenanzahl (S), anpassbar über die Einstellungen
local minVoltage = 3.2 -- Minimalspannung pro Zelle (anpassbar)
local maxVoltage = 4.2 -- Maximalspannung pro Zelle (anpassbar)
local alarmThreshold = 20 -- Alarm ab 20% Restladung
local voltage = 0 -- Gemessene Spannung
local percent = 0 -- Berechneter Prozentsatz des Ladezustands
local voltageDisplayMode = "total" -- Optionen: "single" (Einzelzelle) oder "total" (Gesamtpack)

-- Lade die gespeicherten Einstellungen (falls vorhanden)
local function loadSettings()
    -- Hier könntest du später Einstellungen aus einer JSON-Datei oder aus den Sender-Einstellungen laden
end

-- Berechnung der Batteriespannung in Prozent
local function calculatePercentage(voltage)
    local totalMaxVoltage = cellCount * maxVoltage
    local totalMinVoltage = cellCount * minVoltage
    local totalVoltageRange = totalMaxVoltage - totalMinVoltage
    local voltageRange = voltage - totalMinVoltage

    return math.max(0, math.min(100, (voltageRange / totalVoltageRange) * 100))
end

-- Zeichne Batteriesymbol und ändere die Farben basierend auf dem Batteriestatus
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
    lcd.drawFilledRectangle(x, y, w, h * (percent / 100)) -- Batterieinhalt basierend auf Prozentsatz
    lcd.setColor(lcd.RGB(255, 255, 255)) -- Zurücksetzen auf Weiß
    lcd.drawRectangle(x, y, w, h) -- Batterierahmen zeichnen
end

-- Die Hauptfunktion, die in der Schleife läuft
local function loop()
    -- Telemetrie-Spannungswert abfragen
    voltage = getValue(sensorId) -- Sensor ID muss eingestellt sein

    -- Berechnung des Prozentsatz
