// Copyright (c) Meta Platforms, Inc. and affiliates. (http://www.meta.com)

#include "Jit/config.h"

namespace jit {

namespace {

Config s_config;

} // namespace

const Config& getConfig() {
  return s_config;
}

Config& getMutableConfig() {
  return s_config;
}

} // namespace jit
