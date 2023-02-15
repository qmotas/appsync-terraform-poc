import { util } from "@aws-appsync/utils";

export function request(ctx) {
  return {
    method: "GET",
    params: {
      headers: { "Content-Type": "application/json" },
    },
    resourcePath: `/author/${ctx.source.authorId}`,
  };
}

export function response(ctx) {
  const { error, result } = ctx;
  if (error) {
    ctx.stash.errors = ctx.stash.errors ?? [];
    ctx.stash.errors.push(ctx.error);
    return util.appendError(error.message, error.type, result);
  }

  if (result.statusCode === 200) {
    return JSON.parse(result.body);
  } else {
    return util.appendError(result.body, result.statusCode);
  }
}
