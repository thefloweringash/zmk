/*
 * Copyright (c) 2020 The ZMK Contributors
 *
 * SPDX-License-Identifier: MIT
 */

#pragma once

int zmk_usb_hid_send_report(const uint8_t *report, size_t len);

uint8_t zmk_usb_hid_get_protocol();
void zmk_usb_hid_set_protocol(uint8_t protocol);
