import React from "react"
import { usePriceEstimateContext } from "./ConsignPriceEstimateContext"
import { formatCentsToDollars } from "../../Utils/formatCentsToDollars"

import {
  Box,
  Button,
  Flex,
  Image,
  Separator,
  Spacer,
  Text,
} from "@artsy/palette"
import styled from "styled-components"

export const ArtistInsightResult: React.FC = () => {
  const { artistInsights, selectedSuggestion } = usePriceEstimateContext()

  if (!artistInsights?.marketPriceInsights) {
    return <ZeroState />
  }

  // TODO: Look into why we need to coerce these types from mp
  const lowRangeCents: number = Number(
    artistInsights.marketPriceInsights.lowRangeCents
  )
  const midRangeCents: number = Number(
    artistInsights.marketPriceInsights.midRangeCents
  )
  const highRangeCents: number = Number(
    artistInsights.marketPriceInsights.highRangeCents
  )

  const lowEstimateDollars = formatCentsToDollars(lowRangeCents)
  const highEstimateDollars = formatCentsToDollars(highRangeCents)
  const medianEstimateDollars = formatCentsToDollars(midRangeCents)

  const imageUrl = selectedSuggestion?.node?.imageUrl

  return (
    <Box>
      <Container>
        <Flex>
          <Box pr={4}>
            <Image src={imageUrl} width={120} height={120} />
          </Box>
          <Box>
            <Text variant="largeTitle">
              {artistInsights.marketPriceInsights.artistName}
            </Text>
            <Separator mt={0.5} mb={2} />
            <Text variant="small" color="black60">
              Price estimate
            </Text>
            <Text variant="largeTitle">
              {lowEstimateDollars} – {highEstimateDollars}
            </Text>
            <Text variant="text">Median: {medianEstimateDollars}</Text>
          </Box>
        </Flex>

        <Spacer mb={3} />

        <Box>
          <Text>
            An Artsy specialist can provide a custom valuation for your work.
          </Text>
          <Spacer mb={2} />
          <Button width={230} variant="secondaryOutline" mr={2}>
            Explore auction data
          </Button>
          <Button width={230}>Get a valuation</Button>
        </Box>
      </Container>

      <Spacer my={3} />

      <Flex width="100%" justifyContent="center">
        <Text variant="small" color="black60" maxWidth={495}>
          Price Estimate is based on 36 months of secondary market data for this
          artist + category combination.
        </Text>
      </Flex>
    </Box>
  )
}

const ZeroState: React.FC = () => {
  const { searchQuery } = usePriceEstimateContext()

  return (
    <Container>
      <Box>
        <Text variant="largeTitle">{searchQuery}</Text>
        <Separator mt={0.5} mb={2} />
        <Text variant="small" color="black60">
          Sorry, there isn’t enough secondary market data to provide a price
          estimate for this artist.
        </Text>
        <Spacer mb={3} />
        <Text variant="text">
          The market is unique for every artwork. Log in or sign up to access
          auction result data from thousands of artists.
        </Text>
      </Box>

      <Spacer mb={3} />

      <Box>
        <Button width={230} mr={2}>
          Sign up
        </Button>
        <Button width={230} variant="secondaryOutline">
          Log in
        </Button>
      </Box>
    </Container>
  )
}

const Container = styled(Box).attrs({
  width: 550,
  maxHeight: 320,
  p: 3,
})`
  background: white;
  box-shadow: 0px 2px 10px rgba(0, 0, 0, 0.1);
`