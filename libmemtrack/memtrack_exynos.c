/*
 * Copyright (C) 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <log/log.h>

#include <hardware/memtrack.h>

#include "memtrack_exynos.h"

int exynos_memtrack_init(const struct memtrack_module __unused *module)
{
    return 0;
}

int exynos_memtrack_get_memory(const struct memtrack_module __unused *module,
                                pid_t pid,
                                int type,
                                struct memtrack_record *records,
                                size_t *num_records)
{
    if (type == MEMTRACK_TYPE_GL) {
        return mali_memtrack_get_memory(pid, type, records, num_records);
    } else if (type == MEMTRACK_TYPE_GRAPHICS) {
        return ion_memtrack_get_memory(pid, type, records, num_records);
    }

    return -EINVAL;
}

static int memtrack_open(__attribute__((unused)) const hw_module_t* module, const char* name,
                    hw_device_t** device)
{
    ALOGD("%s: enter; name=%s", __FUNCTION__, name);
    int retval = 0; /* 0 is ok; -1 is error */

    if (strcmp(name, "memtrack") == 0) {
        struct memtrack_module *dev = (struct memtrack_module *)calloc(1,
                sizeof(struct memtrack_module));

        if (dev) {
            /* Common hw_device_t fields */
            dev->common.tag = HARDWARE_DEVICE_TAG;
            dev->common.module_api_version = MEMTRACK_MODULE_API_VERSION_0_1;
            dev->common.hal_api_version = HARDWARE_HAL_API_VERSION;

            dev->init = exynos_memtrack_init;
            dev->getMemory = exynos_memtrack_get_memory;

            *device = (hw_device_t*)dev;
        } else
            retval = -ENOMEM;
    } else {
        retval = -EINVAL;
    }

    ALOGD("%s: exit %d", __FUNCTION__, retval);
    return retval;
}

static struct hw_module_methods_t memtrack_module_methods = {
    .open = memtrack_open,
};

struct memtrack_module HAL_MODULE_INFO_SYM = {
    .common = {
        .tag = HARDWARE_MODULE_TAG,
        .module_api_version = MEMTRACK_MODULE_API_VERSION_0_1,
        .hal_api_version = HARDWARE_HAL_API_VERSION,
        .id = MEMTRACK_HARDWARE_MODULE_ID,
        .name = "Exynos Memory Tracker HAL",
        .author = "The Android Open Source Project",
        .methods = &memtrack_module_methods,
    },

    .init = exynos_memtrack_init,
    .getMemory = exynos_memtrack_get_memory,
};

