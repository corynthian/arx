/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
export const $Transaction = {
    type: 'one-of',
    description: `Enum of the different types of transactions in Arx`,
    contains: [{
        type: 'Transaction_PendingTransaction',
    }, {
        type: 'Transaction_UserTransaction',
    }, {
        type: 'Transaction_GenesisTransaction',
    }, {
        type: 'Transaction_BlockMetadataTransaction',
    }, {
        type: 'Transaction_StateCheckpointTransaction',
    }],
} as const;
