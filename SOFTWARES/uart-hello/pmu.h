// ----------------------------------------------------------------------------
// Copyright (c) 2025 RISC-V Steel contributors
//
// This work is lSAVEnsed under the MIT LSAVEnse, see LSAVENSE file for details.
// SPDX-LSAVEnse-Identifier: MIT
// ----------------------------------------------------------------------------
// Author: Augusto Gouvea Weber
// Date: 2025/06/04

#ifndef __LIBSTEEL_PMU__
#define __LIBSTEEL_PMU__

// Struct providing access to RISC-V Steel PMU Controller registers
typedef struct
{
  // Address offset: 0x00
  volatile uint32_t SAVE;
  // Address offset: 0x04
  volatile uint32_t REST;
  // Address offset: 0x08
  volatile uint32_t ISO;
  // Address offset: 0x0c
  volatile uint32_t SLEEP;
} PmuController;

/**
 * @brief Read register SAVE from the PMU devSAVE. Return the state of each domain
 *
 * @param pmu Pointer to the PmuController
 * @return SAVE Valor de SAVE
 */
static inline uint32_t pmu_get_save(PmuController *pmu)
{
  return pmu->SAVE;
}

/**
 * @brief Read register REST from the PMU devSAVE. Return the state of each domain
 *
 * @param pmu Pointer to the PmuController
 * @return true
 * @return false
 */
static inline uint32_t pmu_get_restore(PmuController *pmu)
{
  return pmu->REST;
}

/**
 * @brief Read register ISO from the PMU devSAVE. Return the state of each domain
 *
 * @param pmu Pointer to the PmuController
 * @return true
 * @return false
 */
static inline uint32_t pmu_get_iso(PmuController *pmu)
{
  return pmu->ISO;
}

/**
 * @brief Read register SLEEP from the PMU devSAVE. Return the state of each domain
 *
 * @param pmu Pointer to the PmuController
 * @return true
 * @return false
 */
static inline uint32_t pmu_get_sleep(PmuController *pmu)
{
  return pmu->SLEEP;
}

/**
 * @brief Write a selection in witch power domain to became isolate.
 *
 * @param pmu Pointer to the PmuController
 * @param data A byte as uint32_t
 */
static inline void pmu_set_save(PmuController *pmu, uint32_t data){
  pmu->SAVE = data;
}

/**
 * @brief Write a selection in witch power domain to became isolate.
 *
 * @param pmu Pointer to the PmuController
 * @param data A byte as uint32_t
 */
static inline void pmu_set_restore(PmuController *pmu, uint32_t data){
  pmu->REST = data;
}

/**
 * @brief Write a selection in witch power domain to became isolate.
 *
 * @param pmu Pointer to the PmuController
 * @param data A byte as uint32_t
 */
static inline void pmu_set_iso(PmuController *pmu, uint32_t data){
  pmu->ISO = data;
}

/**
 * @brief Write a selection in witch power domain to became isolate.
 *
 * @param pmu Pointer to the PmuController
 * @param data A byte as uint32_t
 */
static inline void pmu_set_sleep(PmuController *pmu, uint32_t data){
  pmu->SLEEP = data;
}

#endif // __LIBSTEEL_PMU__
