/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { ArxErrorCode } from './ArxErrorCode';

/**
 * This is the generic struct we use for all API errors, it contains a string
 * message and an Arx API specific error code.
 */
export type ArxError = {
    /**
     * A message describing the error
     */
    message: string;
    error_code: ArxErrorCode;
    /**
     * A code providing VM error details when submitting transactions to the VM
     */
    vm_error_code?: number;
};

