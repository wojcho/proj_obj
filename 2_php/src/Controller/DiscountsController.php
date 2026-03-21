<?php

namespace App\Controller;

use App\Entity\Discount;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[Route('/api/discounts')]
class DiscountsController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function index(EntityManagerInterface $em): JsonResponse
    {
        $discounts = $em->getRepository(Discount::class)->findAll();

        $data = array_map(fn(Discount $d) => [
            'id' => $d->getId(),
            'percentage' => $d->getPercentage(),
            'beginning' => $d->getBeginning()?->format('Y-m-d H:i:s'),
            'ending' => $d->getEnding()?->format('Y-m-d H:i:s'),
        ], $discounts);

        return $this->json($data);
    }

    #[Route('/{id}', methods: ['GET'])]
    public function show(EntityManagerInterface $em, int $id): JsonResponse
    {
        $discount = $em->getRepository(Discount::class)->find($id);

        if (!$discount) {
            return $this->json(['error' => 'Discount not found'], 404);
        }

        return $this->json([
            'id' => $discount->getId(),
            'percentage' => $discount->getPercentage(),
            'beginning' => $discount->getBeginning()?->format('Y-m-d H:i:s'),
            'ending' => $discount->getEnding()?->format('Y-m-d H:i:s'),
        ]);
    }

    #[Route('', methods: ['POST'])]
    public function create(Request $request, EntityManagerInterface $em): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (!isset($data['percentage'], $data['beginning'], $data['ending'])) {
            return $this->json(['error' => 'Invalid data'], 400);
        }

        try {
            $discount = new Discount();
            $discount->setPercentage((string) $data['percentage']);
            $discount->setBeginning(new \DateTime($data['beginning']));
            $discount->setEnding(new \DateTime($data['ending']));
        } catch (\Exception $e) {
            return $this->json(['error' => 'Invalid date format'], 400);
        }

        $em->persist($discount);
        $em->flush();

        return $this->json([
            'id' => $discount->getId(),
            'message' => 'Discount created'
        ], 201);
    }

    #[Route('/{id}', methods: ['PUT'])]
    public function update(int $id, Request $request, EntityManagerInterface $em): JsonResponse
    {
        $discount = $em->getRepository(Discount::class)->find($id);

        if (!$discount) {
            return $this->json(['error' => 'Discount not found'], 404);
        }

        $data = json_decode($request->getContent(), true);

        try {
            if (isset($data['percentage'])) {
                $discount->setPercentage((string) $data['percentage']);
            }

            if (isset($data['beginning'])) {
                $discount->setBeginning(new \DateTime($data['beginning']));
            }

            if (isset($data['ending'])) {
                $discount->setEnding(new \DateTime($data['ending']));
            }
        } catch (\Exception $e) {
            return $this->json(['error' => 'Invalid date format'], 400);
        }

        $em->flush();

        return $this->json(['message' => 'Discount updated']);
    }

    #[Route('/{id}', methods: ['DELETE'])]
    public function delete(int $id, EntityManagerInterface $em): JsonResponse
    {
        $discount = $em->getRepository(Discount::class)->find($id);

        if (!$discount) {
            return $this->json(['error' => 'Discount not found'], 404);
        }

        $em->remove($discount);
        $em->flush();

        return $this->json(['message' => 'Discount deleted']);
    }
}
