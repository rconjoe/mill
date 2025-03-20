export async function main(
  api_key: string,
  channel_id: string,
  part: "snippet",
  maxResults: number,
  type: "video" | "channel" | "playlist",
  order: "date" | "rating" | "relevance" | "title" | "videoCount" | "viewCount",
  publishedAfter?: string,
  publishedBefore?: string,
) {
  if (maxResults < 0 || maxResults > 50) {
    throw new Error("maxResults must be between 0 and 50");
  }

  const headers = {
    "Accept": "application/json"
  }

  const params = {
    part,
    key: api_key,
    channelId: channel_id,
    maxResults: maxResults.toString(),
    type,
    videoEmbeddable: "true",
    order
  };

  const encodedParams = new URLSearchParams(params)

  const response = await fetch(`https://www.googleapis.com/youtube/v3/search?${encodedParams}`, {
    method: "GET",
    headers
  });

  if (!response.ok) {
    throw new Error(`Error fetching data: ${response.statusText}`);
  }

  const data = await response.json();
  return data;
}

