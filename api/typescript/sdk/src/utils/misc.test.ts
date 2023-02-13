// Copyright (c) Arx
// SPDX-License-Identifier: Apache-2.0

import { ArxClient } from "../arx_client";

test("test fixNodeUrl", () => {
  expect(new ArxClient("https://test.com").client.request.config.BASE).toBe("https://test.com/v1");
  expect(new ArxClient("https://test.com/").client.request.config.BASE).toBe("https://test.com/v1");
  expect(new ArxClient("https://test.com/v1").client.request.config.BASE).toBe("https://test.com/v1");
  expect(new ArxClient("https://test.com/v1/").client.request.config.BASE).toBe("https://test.com/v1");
  expect(new ArxClient("https://test.com", {}, true).client.request.config.BASE).toBe("https://test.com");
});
