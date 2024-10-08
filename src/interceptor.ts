// @ts-ignore
import { load } from "./aws/UserFunction";

const ORIGINAL_HANDLER_KEY = "ORIGINAL_HANDLER";

console.log("Original handler: ", process.env[ORIGINAL_HANDLER_KEY]);

export async function handler(event: any, context: any) {
  console.log("INPUT EVENT: ", JSON.stringify(event, null, 2));

  const handler = await getOriginalHandler();

  console.log("HANDLER: ", handler.toString());

  const response = await handler(event, context);

  console.log("RESPONSE: ", JSON.stringify(response, null, 2));
  return response;
}

async function getOriginalHandler(): Promise<any> {
  console.log("LAMBDA_TASK_ROOT: ", process.env.LAMBDA_TASK_ROOT);

  if (process.env[ORIGINAL_HANDLER_KEY] === undefined)
    throw Error("Missing original handler");
  return load(
    process.env.LAMBDA_TASK_ROOT!,
    process.env[ORIGINAL_HANDLER_KEY]
  ) as Promise<any>;
}
