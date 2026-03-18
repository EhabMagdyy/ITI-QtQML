#include "led.hpp"
#include <gpiod.h>

static gpiod_chip *chip = nullptr;
static gpiod_line_request *request = nullptr;

LedController::LedController(QObject *parent) : QObject(parent)
{
    chip = gpiod_chip_open("/dev/gpiochip0");
    if (!chip) return;

    gpiod_request_config *req_cfg = gpiod_request_config_new();
    gpiod_request_config_set_consumer(req_cfg, "led");

    gpiod_line_config *line_cfg = gpiod_line_config_new();
    gpiod_line_settings *settings = gpiod_line_settings_new();
    gpiod_line_settings_set_direction(settings, GPIOD_LINE_DIRECTION_OUTPUT);
    gpiod_line_settings_set_output_value(settings, GPIOD_LINE_VALUE_INACTIVE);
    gpiod_line_config_add_line_settings(line_cfg, (const unsigned int[]){17}, 1, settings);

    request = gpiod_chip_request_lines(chip, req_cfg, line_cfg);

    gpiod_line_settings_free(settings);
    gpiod_line_config_free(line_cfg);
    gpiod_request_config_free(req_cfg);
}

LedController::~LedController()
{
    if (request) gpiod_line_request_release(request);
    if (chip) gpiod_chip_close(chip);
}

void LedController::turnOn()
{
    m_state = true;
    if (request)
        gpiod_line_request_set_value(request, 17, GPIOD_LINE_VALUE_ACTIVE);
}

void LedController::turnOff()
{
    m_state = false;
    if (request)
        gpiod_line_request_set_value(request, 17, GPIOD_LINE_VALUE_INACTIVE);
}

void LedController::toggle()
{
    m_state ? turnOff() : turnOn();
}