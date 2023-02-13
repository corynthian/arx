/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */

import type { ArxError } from './ArxError';

/**
 * Information telling which batch submission transactions failed
 */
export type TransactionsBatchSingleSubmissionFailure = {
    error: ArxError;
    /**
     * The index of which transaction failed, same as submission order
     */
    transaction_index: number;
};

