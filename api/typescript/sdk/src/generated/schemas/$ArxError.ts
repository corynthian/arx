/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
export const $ArxError = {
    description: `This is the generic struct we use for all API errors, it contains a string
    message and an Arx API specific error code.`,
    properties: {
        message: {
            type: 'string',
            description: `A message describing the error`,
            isRequired: true,
        },
        error_code: {
            type: 'ArxErrorCode',
            isRequired: true,
        },
        vm_error_code: {
            type: 'number',
            description: `A code providing VM error details when submitting transactions to the VM`,
            format: 'uint64',
        },
    },
} as const;
