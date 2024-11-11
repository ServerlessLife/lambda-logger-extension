// @ts-ignore
import { load } from "./aws/UserFunction";

const ORIGINAL_HANDLER_KEY = "ORIGINAL_HANDLER";
let originalHandler: any;

export async function handler(event: any, context: any) {
  console.log("INPUT_EVENT: ", JSON.stringify(event, null, 2));

  if (!originalHandler) {
    originalHandler = await getOriginalHandler();
  }

  const response = await originalHandler(event, context);

  console.log("RESPONSE: ", JSON.stringify(response, null, 2));
  return response;
}

async function getOriginalHandler(): Promise<any> {
  if (process.env[ORIGINAL_HANDLER_KEY] === undefined)
    throw Error("Missing original handler name");
  const originalHandler = load(
    process.env.LAMBDA_TASK_ROOT!,
    process.env[ORIGINAL_HANDLER_KEY]
  ) as Promise<any>;

  if (!originalHandler) {
    throw Error("Original handler not found");
  }

  return originalHandler;
}
