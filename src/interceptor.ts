const ORIGINAL_HANDLER_KEY = 'ORIGINAL_HANDLER';

export async function handler(event: any, context: any) {
  const regularHandler = async () => {
    const handler = await getOriginalHandler();
    return await handler(event, context);
  };

  const regularHandlerPromise = regularHandler();

  const response = await regularHandlerPromise;
  return response;
}

async function getOriginalHandler(): Promise<any> {
  // @ts-ignore
  const { load } = await import('./aws/UserFunction');

  if (process.env[ORIGINAL_HANDLER_KEY] === undefined)
    throw Error('Missing original handler');
  return load(
    process.env.LAMBDA_TASK_ROOT!,
    process.env[ORIGINAL_HANDLER_KEY],
  ) as Promise<any>;
}
